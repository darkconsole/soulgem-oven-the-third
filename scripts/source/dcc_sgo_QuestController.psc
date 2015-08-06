Scriptname dcc_sgo_QuestController extends Quest
{The main API controlpoint for Soulgem Oven 3.}

;/*****************************************************************************
  _______             __                          _______                   
 |   _   .-----.--.--|  .-----.-----.--------.   |   _   .--.--.-----.-----.
 |   1___|  _  |  |  |  |  _  |  -__|        |   |.  |   |  |  |  -__|     |
 |____   |_____|_____|__|___  |_____|__|__|__|   |.  |   |\___/|_____|__|__|
 |:  1   |              |_____|                  |:  1   |                  
 |::.. . |                                       |::.. . |                  
 `-------'                                       `-------'                  
        _______ __              _______ __    __         __                 
       |       |  |--.-----.   |       |  |--|__.----.--|  |                
       |.|   | |     |  -__|   |.|   | |     |  |   _|  _  |                
       `-|.  |-|__|__|_____|   `-|.  |-|__|__|__|__| |_____|                
         |:  |                   |:  |                                      
         |::.|                   |::.|                                      
         `---'                   `---'                                      
*****************************************************************************/;

;; >
;; THERE ARE ONLY 6 SOULGEM
;; MODELS.

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; StorageUtil Keys (Global) ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; FormList SGO.ActorList.Gem - list all actors currently growing gems.
;; FormList SGO.ActorList.Milk - list all actors currently producing milk.

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; StorageUtil Keys (Actor) ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Float    SGO.Actor.Time.Gem - the last time this actor's gem data updated.
;; Float    SGO.Actor.Time.Milk - the last time this actor's milk data updated.
;; Float[]  SGO.Actor.Data.Gem - the gem data for this actor.
;; Float    SGO.Actor.Data.Milk - the milk data for this actor.
;; String[] SGO.Actor.Mod.ScaleBelly
;; String[] SGO.Actor.Mod.ScaleBellyMax
;; String[] SGO.Actor.Mod.ScaleBreast
;; String[] SGO.Actor.Mod.ScaleBreastMax
;; String[] SGO.Actor.Mod.GemProductionRate
;; String[] SGO.Actor.Mod.GemProductionTime
;; String[] SGO.Actor.Mod.MilkProductionRate
;; String[] SGO.Actor.Mod.MilkProductionTime


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Method List ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; these are the methods which have been designed to be used by mods that wish
;; to integrate with soulgem oven.

;; Float SGO.ActorGetGemWeight(Actor Who)
;; Float SGO.ActorGetMilkWeight(Actor Who)
;; Float SGO.ActorGetTimeSinceUpdate(Actor Who, String What)
;; Void  SGO.ActorSetTimeUpdated(Actor Who, String What[, Float When])
;; Void  SGO.ActorTrackForGems(Actor Who, Bool Enabled)
;; Void  SGO.ActorTrackForMilk(Actor who, Bool Enabled)
;; Void  SGO.ActorUpdateGemData(Actor Who, Bool Force)
;; Void  SGO.ActorUpdateMilkData(Actor Who, Bool Force)
;; Float SGO.ActorModGetTotal(Actor Who, String What)
;; Float SGO.ActorModGetValue(Actor Who, String What, String ModKey)
;; Void  SGO.ActorModSetValue(Actor Who, String What, String ModKey)
;; Void  SGO.ActorModUnsetValue(Actor Who, String What, String ModKey)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Event List ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; events emitted by this mod that can be watched for by mods that wish to
;; integrate with soulgem oven.

;; SGO.OnGemProgress ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Actor Who, Int No, Int Pet, Int Les, Int Com, Int Gre, Int Gra, Int Bla
;; This event describes the number of gems the specified actor is carrying in
;; the various states of development. It is emitted any time a gem crosses
;; into the next stage.

;; SGO.OnMilkProgress ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Actor Who, Int Amount
;; This event describes how many bottles of milk the specified actor is
;; carrying. It is emitted any time another whole bottle is ready.

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; NiOverride Keys ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; SGO.Scale on NPC Belly
;; SGO.Scale on NPC L Breast
;; SGO.Scale on NPC R Breast

;/*****************************************************************************
                                    __   __             
 .-----.----.-----.-----.-----.----|  |_|__.-----.-----.
 |  _  |   _|  _  |  _  |  -__|   _|   _|  |  -__|__ --|
 |   __|__| |_____|   __|_____|__| |____|__|_____|_____|
 |__|             |__|                                  

*****************************************************************************/;

Bool  Property OK = FALSE Auto Hidden
{this will be set to true if everything this mod needs to run has been found
and accessible during startup or reset.}

;; scripts n stuff ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Actor Property Player Auto
{maintain a pointer to player. set via ck.}

dcc_sgo_QuestController_UpdateLoop Property UpdateLoop Auto
{the script that will handle the update queue. set via ck.}

SexLabFramework Property SexLab Auto Hidden
{the sexlab framework scripting. it will be set by the dependency checker.}

;; mod forms ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Perk Property dcc_sgo_PerkCannotProduceGems Auto
{prevent an actor from producing gems if it normally could.}

Perk Property dcc_sgo_PerkCanProduceGems Auto
{allow an actor to produce gems if it normally could not.}

Perk Property dcc_sgo_PerkCannotProduceMilk Auto
{prevent an actor from producing milk if it normally could.}

Perk Property dcc_sgo_PerkCanProduceMilk Auto
{allow an actor to produce milk if it normally could not}

Perk Property dcc_sgo_PerkCannotInseminate Auto
{prevent an actor from inseminating others if it normally could.}

Perk Property dcc_sgo_PerkCanInseminate Auto
{allow an actor to inseminate others if it normally could not.}

;; gameplay options ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Float Property OptGemMatureTime Auto Hidden
{how many hours for a gem to mature. default 144 = 6 days.}

Int Property OptGemMaxCapacity Auto Hidden
{how many gems can be carried at one time.}

Float Property OptMilkProduceTime Auto Hidden
{how many hours for milk to produce. default 8 = 3 per day.}

Int Property OptMilkMaxCapacity Auto Hidden
{how many bottles of milk can be carried at one time.}

Float Property OptScaleBellyMax Auto Hidden
{the maximum size of the belly when full up.}

Float Property OptScaleBreastMax Auto Hidden
{the maximum size of the breasts when filled up.}

Int Property OptPregChanceHumanoid Auto Hidden
{preg chance on encounters with people.}

Int Property OptPregChanceBeast Auto Hidden
{preg chance on encounters with beasts.}

;; mod options ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Bool  Property OptDebug Auto Hidden
{print debugging information out to the console}

Float Property OptUpdateInterval Auto Hidden
{how long to wait before beginning the calculation queue again.}

Float Property OptUpdateDelay Auto Hidden
{how long to delay the update loop each iteration.}

;; Constants ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Int Property BioCanProduceGems = 1 AutoReadOnly
Int Property BioCanProduceMilk = 2 AutoReadOnly
Int Property BioCanInseminate  = 4 AutoReadOnly
Int Property BioIsBeast        = 8 AutoReadOnly

;/*****************************************************************************
                     __                      __              __ 
 .--------.-----.--|  |   .----.-----.-----|  |_.----.-----|  |
 |        |  _  |  _  |   |  __|  _  |     |   _|   _|  _  |  |
 |__|__|__|_____|_____|   |____|_____|__|__|____|__| |_____|__|

*****************************************************************************/;

Function ResetMod()
{perform a quest (and ergo mod) reboot. quest RunOnce is disabled so that we
trigger OnInit() to finish the deal.}

	self.Reset()
	self.Stop()
	self.Start()
	Return
EndFunction

Function ResetMod_Prepare()
{check that everything this mod needs to run exists and is ready.}

	If(!self.IsInstalledNiOverride())
		Return
	EndIf

	If(!self.IsInstalledUIExtensions())
		Return
	EndIf

	If(!self.IsSexLabInstalled())
		Return
	EndIf

	self.OK = TRUE
	Return
EndFunction

Function ResetMod_Values()
{force reset settings to default values.}

	self.OptGemMatureTime = 144.0
	self.OptGemMaxCapacity = 6
	self.OptMilkProduceTime = 8.0
	self.OptMilkMaxCapacity = 3
	self.OptScaleBellyMax = 3.0
	self.OptScaleBreastMax = 0.75
	self.OptPregChanceHumanoid = 75
	self.OptPregChanceBeast = 10
	self.OptDebug = TRUE
	self.OptUpdateInterval = 10.0
	self.OptUpdateDelay = 0.125

	Return
EndFunction

Function ResetMod_Events()
{cleanup and reinit of any event handling things.}

	self.UnregisterForModEvent("OrgasmStart")
	self.UpdateLoop.UnregisterForUpdate()

	If(!self.OK)
		;; we allowed this method to do a cleanup, but if the mod is not
		;; satisified we will not re-engage events.
		Return
	EndIf

	self.RegisterForModEvent("OrgasmStart","OnEncounterEnding")
	self.UpdateLoop.RegisterForSingleUpdate(self.OptUpdateInterval)
	Return
EndFunction

Function Print(String Msg)
	Debug.Notification("[SGO] " + Msg)
	Return
EndFunction

Function PrintDebug(String Msg)
	If(!self.OptDebug)
		Return
	EndIf

	MiscUtil.PrintConsole("[SGO] " + Msg)
	Return
EndFunction

;/*****************************************************************************
     __                            __                        
 .--|  .-----.-----.-----.-----.--|  .-----.-----.----.--.--.
 |  _  |  -__|  _  |  -__|     |  _  |  -__|     |  __|  |  |
 |_____|_____|   __|_____|__|__|_____|_____|__|__|____|___  |
             |__|                                     |_____|
                                                             
*****************************************************************************/;

Bool Function IsInstalledNiOverride(Bool Popup=TRUE)
{make sure NiOverride is installed and active.}

	If(SKSE.GetPluginVersion("NiOverride") == -1)
		If(Popup)
			Debug.MessageBox("NiOverride not installed. Install it by installing RaceMenu or by installing it standalone from the Nexus.")
		EndIf
		Return FALSE
	EndIf

	Return TRUE
EndFunction

Bool Function IsInstalledUIExtensions(Bool Popup=TRUE)
{make sure UIExtensions is installed and active.}

	If(Game.GetModByName("UIExtensions.esp") == 255)
		If(Popup)
			Debug.MessageBox("UIExtensions not installed. Install it from the Nexus.")
		EndIf
		Return FALSE
	EndIf

	Return TRUE
EndFunction

Bool Function IsSexLabInstalled(Bool Popup=TRUE)
{make sure SexLab is installed and active.}

	If(Game.GetModByName("SexLab.esm") == 255)
		If(Popup)
			Debug.MessageBox("SexLab not installed. Install it from LoversLab.")
		EndIf
		Return FALSE
	EndIf

	self.SexLab = Game.GetFormFromFile(0xD62,"SexLab.esm") as SexLabFramework
	Return TRUE
EndFunction

;/*****************************************************************************
                          __         
 .-----.--.--.-----.-----|  |_.-----.
 |  -__|  |  |  -__|     |   _|__ --|
 |_____|\___/|_____|__|__|____|_____|
                                                             
*****************************************************************************/;

Event OnInit()
	self.OK = FALSE
	self.ResetMod_Prepare()
	self.ResetMod_Values()
	self.ResetMod_Events()

	self.Print("Mod Installed.")
	If(self.OK)
		self.Print("Mod Active.")
	Else
		self.Print("Mod Inactive - Go fix missing dependencies.")
	EndIf
	
	Return
EndEvent

Event OnEncounterEnding(String EventName, String Args, Float Argc, Form From)
	
	self.PrintDebug("OnEncounterEnding Fired")

	Actor[] ActorList = SexLab.HookActors(Args)
	Int[] ActorBio = PapyrusUtil.IntArray(ActorList.Length)
	sslBaseAnimation Animation = SexLab.HookAnimation(Args)
	Int PartyBio = 0
	Int MaleCount = 0
	Int BeastCount = 0
	Bool Preg = 0
	Int x

	;;;;;;;;
	;;;;;;;;

	;; check if the animation type even included penetration.

	If(!Animation.IsVaginal && !Animation.IsAnal)
		self.PrintDebug("Encounter did not have penetration (vag/anal).")
		Return
	EndIf


	;;;;;;;;
	;;;;;;;;

	;; we need to go through the party and determine which biological
	;; features they are capable of providing to the mix. because of the way
	;; SexLab animations and just how you play the game in general works,
	;; all characters able to recieve bounties will get them if there is at
	;; least one character able to produce them. we cannot really reliably
	;; trust who is the pitcher and who is the catcher with the animations
	;; even more so when there is more than two actors.

	x = 0
	While(x < ActorList.Length)
		ActorBio[x] = self.ActorGetBiologicalFunctions(ActorList[x])
		PartyBio = Math.LogicalOr(PartyBio,ActorBio[x])

		;; determine what pitchers we have for determining which preg
		;; chance to use.
		If(Math.LogicalAnd(ActorBio[x],self.BioIsBeast) > 0)
			BeastCount += 1
		ElseIf(Math.LogicalAnd(ActorBio[x],self.BioCanInseminate) > 0)
			MaleCount += 1
		EndIf

		x += 1
	EndWhile

	If(Math.LogicalAnd(PartyBio,5) != 5)
		;; if we didn't have a winning combination of fuel and ovens
		;; available there is no point in proceeeding.
		self.PrintDebug("Encounter did not have a viable combo (" + PartyBio + ").")
		Return
	EndIf

	;;;;;;;;
	;;;;;;;;

	x = 0
	While(x < ActorList.Length)
		If(MaleCount > 0)
			Preg = (self.OptPregChanceHumanoid >= Utility.RandomInt(0,100))
		Else
			Preg = (self.OptPregChanceBeast >= Utility.RandomInt(0,100))
		EndIf

		If(Preg)
			self.PrintDebug("Preg Chance Success for " + ActorList[x].GetDisplayName())
		Else
			self.PrintDebug("Preg Chance Fail for " + ActorList[x].GetDisplayName())
		EndIf

		If(Preg && Math.LogicalAnd(ActorBio[x],self.BioCanProduceGems) > 0)
			self.PrintDebug(ActorList[x].GetDisplayname() + " will produce gems.")
			self.ActorTrackForGems(ActorList[x],True)
			self.ActorAddGem(ActorList[x])
		EndIf

		If(Preg && Math.LogicalAnd(ActorBio[x],self.BioCanProduceMilk) > 0)
			self.PrintDebug(ActorList[x].GetDisplayName() + " will produce milk.")
			self.ActorTrackForMilk(ActorList[x],True)
		EndIf

		x += 1
	EndWhile

	Return
EndEvent

Function EventSendGemProgress(Actor Who, Int[] Progress)
{emit an event listing the current state of the gems being carried.}

	Int e = ModEvent.Create("SGO.OnGemProgress")

	;; fml, you cannot push an array into mod events.

	If(e)
		ModEvent.PushForm(e,Who)
		ModEvent.PushInt(e,Progress[0]) ;; unready gems
		ModEvent.PushInt(e,Progress[1]) ;; petty gems
		ModEvent.PushInt(e,Progress[2]) ;; lesser gems
		ModEvent.PushInt(e,Progress[3]) ;; common gems
		ModEvent.PushInt(e,Progress[4]) ;; greater gems
		ModEvent.PushInt(e,Progress[5]) ;; grand gems
		ModEvent.PushInt(e,Progress[6]) ;; black gems
		ModEvent.Send(e)
	EndIf

	Return
EndFunction

Function EventSendMilkProgress(Actor Who, Int Progress)
{emit an event stating the current amount of milk being carried.}

	Int e = ModEvent.Create("SGO.OnMilkProgress")

	If(e)
		ModEvent.PushForm(e,Who)
		ModEvent.PushInt(e,Progress)
		ModEvent.Send(e)
	EndIf

	Return
EndFunction

;/*****************************************************************************
             __                     __       __         
 .---.-.----|  |_.-----.----.   .--|  .---.-|  |_.---.-.
 |  _  |  __|   _|  _  |   _|   |  _  |  _  |   _|  _  |
 |___._|____|____|_____|__|     |_____|___._|____|___._|
                                                        
*****************************************************************************/;

Int Function ActorGetBiologicalFunctions(Actor Who)
{determine what this actor's body is able to accomplish.}

	Int Value = 0
	Int Sex = SexLab.GetGender(Who)

	If(Sex == 2)
		Value += self.BioIsBeast
	EndIf

	If((Sex != 1 || Who.HasPerk(self.dcc_sgo_PerkCanInseminate)) && !Who.HasPerk(self.dcc_sgo_PerkCannotInseminate))
		Value += self.BioCanInseminate
	EndIf

	If((Sex == 1 || Who.HasPerk(self.dcc_sgo_PerkCanProduceGems)) && !Who.HasPerk(self.dcc_sgo_PerkCannotProduceGems))
		Value += self.BioCanProduceGems
	EndIf

	If((Sex == 1 || Who.HasPerk(self.dcc_sgo_PerkCanProduceMilk)) && !Who.HasPerk(self.dcc_sgo_PerkCannotProduceMilk))
		Value += self.BioCanProduceMilk
	EndIf

	Return Value
EndFunction

Float Function ActorGetTimeSinceUpdate(Actor Who, String What)
{return how many game hours have passed since this actors specified data has
been updated. the string value is the storageutil name for the data you want.}

	Float Current = Utility.GetCurrentGameTime()
	Float Last = StorageUtil.GetFloatValue(Who,What,0.0)

	If(Last == 0.0)
		StorageUtil.SetFloatValue(Who,What,Current)
		Last = Current
	EndIf

	Return (Current - Last) * 24.0
EndFunction

Function ActorSetTimeUpdated(Actor Who, String What, Float When=0.0)
{set the current time to mark this actor having been updated. the string value
is the storageutil name for the data you want.}

	If(When == 0.0)
		When = Utility.GetCurrentGameTime()
	EndIf

	StorageUtil.SetFloatValue(Who,What,When)
	Return
EndFunction

;/*****************************************************************************
             __                              __                       __       
 .---.-.----|  |_.-----.----.   .--.--.---.-|  |   .--------.-----.--|  .-----.
 |  _  |  __|   _|  _  |   _|   |  |  |  _  |  |   |        |  _  |  _  |__ --|
 |___._|____|____|_____|__|      \___/|___._|__|   |__|__|__|_____|_____|_____|

*****************************************************************************/;

Float Function ActorModGetTotal(Actor Who, String What)
{fetch the sum of all the mods so.}

	What = "SGO.Actor.Mod." + What

	Int x
	Int Count = StorageUtil.StringListCount(Who,What)
	String ModKey
	Float Value
	
	x = 0
	While(x < Count)
		ModKey = StorageUtil.StringListGet(Who,What,x)
		Value += StorageUtil.GetFloatValue(Who,ModKey)
		x += 1
	EndWhile

	Return Value
EndFunction

Float Function ActorModGetValue(Actor Who, String ModKey)
{fetch the specified actor mod.}

	ModKey = "SGO.ActorModValue." + ModKey

	Return StorageUtil.GetFloatValue(Who,ModKey,0.0)
EndFunction

Function ActorModSetValue(Actor Who, String What, String ModKey, Float Value=0.0)
{set a specified actor mod.}

	What = "SGO.Actor.Mod." + What
	ModKey = "SGO.ActorModValue." + ModKey

	StorageUtil.StringListAdd(Who,What,ModKey,FALSE)
	StorageUtil.SetFloatValue(Who,ModKey,Value)

	Return
EndFunction

Function ActorModUnsetValue(Actor Who, String What, String ModKey)
{remove a specified actor mod.}

	What = "SGO.Actor.Mod." + What
	ModKey = "SGO.ActorModValue." + ModKey

	StorageUtil.StringListRemove(Who,What,ModKey,TRUE)
	StorageUtil.UnsetFloatValue(Who,ModKey)

	Return
EndFunction

;/*****************************************************************************
  __                   __    __                             __ 
 |  |_.----.---.-.----|  |--|__.-----.-----.   .---.-.-----|__|
 |   _|   _|  _  |  __|    <|  |     |  _  |   |  _  |  _  |  |
 |____|__| |___._|____|__|__|__|__|__|___  |   |___._|   __|__|
                                     |_____|         |__|      

*****************************************************************************/;

Function ActorTrackForGems(Actor Who, Bool Enabled)
{place or remove an actor from the list tracking actors who are growing gems}

	If(Enabled)
		StorageUtil.FormListAdd(None,"SGO.ActorList.Gem",Who,False)
	Else
		StorageUtil.FormListRemove(None,"SGO.ActorList.Gem",Who,True)
		StorageUtil.UnsetFloatValue(Who,"SGO.Actor.Time.Gem")
		StorageUtil.FloatListClear(Who,"SGO.Actor.Data.Gem")
	EndIf

	Return
EndFunction

Function ActorTrackForMilk(Actor Who, Bool Enabled)
{place or remove an actor from the list tracking actors generating milk.}

	If(Enabled)
		StorageUtil.FormListAdd(None,"SGO.ActorList.Milk",Who,False)
	Else
		StorageUtil.FormListRemove(None,"SGO.ActorList.Milk",Who,True)
		StorageUtil.UnsetFloatValue(Who,"SGO.Actor.Time.Milk")
		StorageUtil.UnsetFloatValue(Who,"SGO.Actor.Data.Milk")
	EndIf

	Return
EndFunction

;/*****************************************************************************
  __             __                       __ 
 |  |--.-----.--|  .--.--.   .---.-.-----|__|
 |  _  |  _  |  _  |  |  |   |  _  |  _  |  |
 |_____|_____|_____|___  |   |___._|   __|__|
                   |_____|         |__|      

*****************************************************************************/;

Function ActorUpdateBody(Actor Who)
{push the updated visual data into NiOverride. cheers to Groovtama for helping
witht he NiO stuffs.}

	self.ActorUpdateBody_BellyScale(Who)
	self.ActorUpdateBody_BreastScale(Who)
	Return
EndFunction

Function ActorUpdateBody_BellyScale(Actor Who)
{handle the physical representation of the belly.}

	Float Belly = 1.0 + self.ActorModGetTotal(Who,"ScaleBelly")
	Bool Female = (Who.GetActorBase().GetSex() == 1)

	;;;;;;;;;;;;;;;;
	;;;;;;;;;;;;;;;;

	Int x = 0
	Int Count = StorageUtil.FloatListCount(Who,"SGO.Actor.Data.Gem")
	Float Weight = 0.0
	Float Current

	While(x < Count)
		Current = StorageUtil.FloatListGet(Who,"SGO.Actor.Data.Gem",x)
		If(Current > 6.0)
			Current = 6.0
		EndIf

		Weight += Current
		x += 1
	EndWhile

	;; with a max of six gems, max of 300% more visual
	;; depending on how the visual results look we may want to curve this value.
	;; to scale less at higher volumes.
	;; 0 gems (( 0 / 36) * 3.0) + 1 == 1.0
	;; 6 gems ((36 / 36) * 3.0) + 1 == 4.0

	Belly = ((Weight / (6 * self.OptGemMaxCapacity)) * (self.OptScaleBellyMax + self.ActorModGetTotal(Who,"ScaleBellyMax"))) + 1
	self.PrintDebug(Who.GetDisplayName() + " Belly Scale " + Belly)

	;;;;;;;;;;;;;;;;
	;;;;;;;;;;;;;;;;

	If(Belly == 1.0)
		NiOverride.RemoveNodeTransformScale((Who as ObjectReference),FALSE,Female,"NPC Belly","SGO.Scale")
	Else
		NiOverride.AddNodeTransformScale((Who as ObjectReference),FALSE,Female,"NPC Belly","SGO.Scale",Belly)
	EndIf

	NiOverride.UpdateNodeTransform((Who as ObjectReference),FALSE,Female,"NPC Belly")
	Return
EndFunction

Function ActorUpdateBody_BreastScale(Actor Who)
{handle the physical representation of the breasts.}
	
	Float Breast = 1.0
	Bool Female = (Who.GetActorBase().GetSex() == 1)

	;;;;;;;;;;;;;;;;
	;;;;;;;;;;;;;;;;

	;; with a max of 3 bottles, max of 200% more visual
	;; 0 milk ((0 / 3) * 2.0) + 1 == 1.0
	;; 3 milk ((3 / 3) * 2.0) + 1 == 3.0

	Breast = ((StorageUtil.GetFloatValue(Who,"SGO.Actor.Data.Milk") / self.OptMilkMaxCapacity) * self.OptScaleBreastMax) + 1
	self.PrintDebug(Who.GetDisplayName() + " Breast Scale " + Breast)

	;;;;;;;;;;;;;;;;
	;;;;;;;;;;;;;;;;

	If(Breast == 1.0)
		NiOverride.RemoveNodeTransformScale((Who as ObjectReference),FALSE,Female,"NPC L Breast","SGO.Scale")
		NiOverride.RemoveNodeTransformScale((Who as ObjectReference),FALSE,Female,"NPC R Breast","SGO.Scale")
	Else
		NiOverride.AddNodeTransformScale((Who as ObjectReference),FALSE,Female,"NPC L Breast","SGO.Scale",Breast)
		NiOverride.AddNodeTransformScale((Who as ObjectReference),FALSE,Female,"NPC R Breast","SGO.Scale",Breast)
	EndIf

	NiOverride.UpdateNodeTransform((Who as ObjectReference),FALSE,Female,"NPC L Breast")
	NiOverride.UpdateNodeTransform((Who as ObjectReference),FALSE,Female,"NPC R Breast")
	Return
EndFunction

;/*****************************************************************************
                                       __ 
 .-----.-----.--------.   .---.-.-----|__|
 |  _  |  -__|        |   |  _  |  _  |  |
 |___  |_____|__|__|__|   |___._|   __|__|
 |_____|                        |__|      
                                          
*****************************************************************************/;

Function ActorAddGem(Actor Who)
{add another gem to this actor's pipeline.}

	If(StorageUtil.FloatListCount(Who,"SGO.Actor.Data.Gem") < self.OptGemMaxCapacity)
		StorageUtil.FloatListAdd(Who,"SGO.Actor.Data.Gem",0.0,TRUE)
		self.Print(Who.GetDisplayName() + " is incubating another gem. (" + StorageUtil.FloatListCount(Who,"SGO.Actor.Data.Gem") + ")")	
	EndIf

	Return
EndFunction

Float Function ActorGetGemWeight(Actor Who, Bool Overflow=FALSE)
{find the current gem weight being carried.}

	Int Count = StorageUtil.FloatListCount(Who,"SGO.Actor.Data.Gem")
	Float Weight = 0.0
	Float Current = 0.0
	Int x = 0

	While(x < Count)
		Current = StorageUtil.FloatListGet(Who,"SGO.Actor.Data.Gem",x)
		If(!Overflow && Current > 6)
			Current = 6
		EndIf

		Weight += Current
		x += 1
	EndWhile

	Return Weight
EndFunction

Function ActorUpdateGemData(Actor Who, Bool Force=FALSE)
{cause this actor to have its gem data recalculated. it will generate an array
that is a snapshot of the current gem states, and that snapshot will be emitted
in a mod event if a gem reached the next stage. this is probably the heaviest
function in this mod, as data is flying in and out of papyrusutil constantly.}

	Float Time = self.ActorGetTimeSinceUpdate(Who,"SGO.Actor.Time.Gem")
	If(Time < 1.0 && !Force)
		;; no need to recalculate this actor more than once a game hour.
		self.PrintDebug(Who.GetDisplayName() + " skipping gem calc(" + Time + ").")
		Return
	EndIf

	;;;;;;;;
	;;;;;;;;

	;; we allow gems to grow larger than 6 for a mechanic later where we
	;; will force labour if you wait too long. bodyscaling will clamp it
	;; to six for the scales though.

	Int[] Progress = new Int[7]
	Bool Progressed = FALSE
	Int Count = StorageUtil.FloatListCount(Who,"SGO.Actor.Data.Gem")

	Float Gem
	Float Before
	Int x = 0
	While(x < Count)
		Gem = StorageUtil.FloatListGet(Who,"SGO.Actor.Data.Gem",x)
		Before = Gem

		;; if mature time = 24hr, processed once an hour
		;; 1 / 24 = 0.0416666/hr * 24 = 1 = one level per day = wrong
		;; (1 / 24) * 6 = 0.25/hr * 24 = 6 = six level per day = right

		;; if mature time = 144hr (6d), processed once an hour
		;; (1 / 144) * 6 = 0.0416/hr * 24 = 1 = one level per day = right

		Gem += ((Time / self.OptGemMatureTime) * 6)
		If(Gem > 12)
			Gem = 12
		EndIf

		If(Gem <= 6)
			Progress[Gem as Int] = Progress[Gem as Int] + 1
		Else
			Progress[6] = Progress[6] + 1
		EndIf

		If(Before as Int != Gem as Int)
			;; if the gem reached the next stage then mark it down
			;; so we can emit an event listing the progression.
			Progressed = TRUE
		EndIf
		
		StorageUtil.FloatListSet(Who,"SGO.Actor.Data.Gem",x,Gem)
		x += 1
	EndWhile
	self.ActorSetTimeUpdated(Who,"SGO.Actor.Time.Gem")

	;;;;;;;;
	;;;;;;;;

	If(Progressed)
		self.EventSendGemProgress(Who,Progress)
	EndIf
	
	self.ActorUpdateBody_BellyScale(Who)
	Return
EndFunction

;/*****************************************************************************
           __ __ __                    __ 
 .--------|__|  |  |--.   .---.-.-----|__|
 |        |  |  |    <    |  _  |  _  |  |
 |__|__|__|__|__|__|__|   |___._|   __|__|
                                |__|      

*****************************************************************************/;

Function ActorUpdateMilkData(Actor Who, Bool Force=FALSE)
{cause this actor to have its milk data recalculated. if we have gained another
full bottle then emit a mod event saying how many bottles are ready to go.}

	Float Time = self.ActorGetTimeSinceUpdate(Who,"SGO.Actor.Time.Milk")

	If(Time < 1.0 && !Force)
		;; no need to recalculate this actor more than once a game hour.
		self.PrintDebug(Who.GetDisplayName() + " skipping milk calc (" + Time + ").")
		Return
	EndIf

	;;;;;;;;
	;;;;;;;;

	Float Milk = StorageUtil.GetFloatValue(Who,"SGO.Actor.Data.Milk",0.0)
	Float Before = Milk

	;; produce time 8hr (3/day), once an hour
	;; 1 / 8 = 0.125/hr * 24 = 3 = three per day = right

	Milk += (Time / self.OptMilkProduceTime)
	If(Milk > self.OptMilkMaxCapacity)
		Milk = self.OptMilkMaxCapacity
	EndIf

	StorageUtil.SetFloatValue(Who,"SGO.Actor.Data.Milk",Milk)
	self.ActorSetTimeUpdated(Who,"SGO.Actor.Time.Milk")

	;;;;;;;;
	;;;;;;;;

	If(Before as Int != Milk as Int)
		self.EventSendMilkProgress(Who,(Milk as Int))
	EndIf

	self.ActorUpdateBody_BreastScale(Who)
	Return
EndFunction

Float Function ActorGetMilkWeight(Actor Who)
{find the current milk weight being carried.}

	Return StorageUtil.GetFloatValue(Who,"SGO.Actor.Data.Milk")
EndFunction

Float Function ActorGetMilkProductionFactor(Actor Who)
{figure out how fast this actor should be generating milk.}

	Return (self.ActorGetGemWeight(Who) / (6 * self.OptGemMaxCapacity)) + self.ActorModGetTotal(Who,"MilkProductionFactor")
EndFunction
