/*Class: SL_ctrl_ProjectLogList 
 *By: Dane Kim
 *On: 5/3/2018 
 *Purpose: Extension used with ProjectLogList Visualforce page. Extends of standard controller for 
 *psa_Proj__c object and used with sl_InlineEditList component. The corresponding page to this controller
 *uses apex:tabpanel and apex:tab with each having its own sl_InlineEditList component. This controller 
 *manages which tab has an active component.
*/
public class SL_ctrl_ProjectLogList{
	
    public final pse__Proj__c objProject;
    public List<componentTab> listOfTabs {get; set;}
    public componentTab tab1{get; set;}
	public componentTab tab2{get; set;}
    public componentTab tab3{get; set;}
    public componentTab tab4{get; set;}
    public string parentFieldId = Label.Projec_log_parent_Id_field_id;
    Public string parentName;
    //Used to reconstruct the correct component based on active tab.
    public String currentTab{get; 
                             set{
                                 this.currentTab = value;
                                 switchTabs();
                             }}
 
    public SL_ctrl_ProjectLogList(ApexPages.StandardController stdController){   
        
        this.objProject = (pse__Proj__c)stdController.getRecord();
        //create a controller-side instace of each tab
        this.tab1 = new componentTab('tab1',TRUE);
        this.tab2 = new componentTab('tab2',FALSE);
        this.tab3 = new componentTab('tab3',FALSE);
        this.tab4 = new componentTab('tab4',FALSE);
        this.listOfTabs = new List<componentTab>{tab1,tab2,tab3,tab4};
        //parent name retrieved for populating looks for NEW button
        this.parentName = [Select Name from pse__Proj__c where Id =:  this.objProject.Id][0].Name;
        
    }
    
    //swicthes active tabs
    public void switchTabs(){
        
        for(componentTab tab : listOfTabs){
            if(tab.Name.equals(currentTab)){
                tab.isActive = true;
            }
            else{
            	tab.isActive = false;
            }
        }   
    }
    
    /*Below is where we create/destry the related list for each tab. May want to condense this with a helper method that actually creates the 
     * sl_InlineEditList component, which is dynamically rendered (apex:dynamiccomponent)
     */
    
	//Returns sl_InlineEditList component for Issue record type of Project Log objects if tab is active. Otherwise, returns nothing.
    public Component.c.sl_InlineEditList getIssuesList() {

        if(tab1.isActive){
        	Component.c.sl_InlineEditList issuesList = new Component.c.sl_InlineEditList( 
                												listName='Issues',
                												rtName='Issue',
                												aParentFieldId=parentFieldId,
                												aParentName=parentName,
            													Id='issueslist', 
                												rendered = true,aQueryParams= 'RecordType.Name = \'Issue\'', 
                												aParentId = objProject.Id,
            													someColumnNames='Description__c,Status__c,Date_Identified__c,Issue_Severity__c,Issue_Type__c,Owner__c,Display_on_Status_Report__c', 
			            										object='Project_Log__c' );

            return issuesList;
        }
        return null;
    }

    //Returns sl_InlineEditList component for Risk record type of Project Log objects if tab is active. Otherwise, returns nothing.
    public Component.c.sl_InlineEditList getRiskList() {
        
        if(tab2.isActive){
        	Component.c.sl_InlineEditList riskList = new Component.c.sl_InlineEditList(
                												listName='Risks',rtName='Risk',
            													aParentFieldId=parentFieldId,
                												aParentName=parentName,												
                												Id='riskList', 
                												rendered = true,
                												aQueryParams= 'RecordType.Name = \'Risk\'', 
                												aParentId = objProject.Id,
																someColumnNames='Description__c,Status__c,Date_Identified__c,Risk_Event__c,Risk_Score__c,Owner__c,Display_on_Status_Report__c',
                												object='Project_Log__c');

            return riskList;
        }
        return null;
    }
    
    //Returns sl_InlineEditList component for Action Item record type of Project Log objects if tab is active. Otherwise, returns nothing.
	public Component.c.sl_InlineEditList getActionItemList() {
        
        if(tab3.isActive){
            Component.c.sl_InlineEditList ActionItemList = new Component.c.sl_InlineEditList(
                												listName='Action Items',
                												rtName='Action Item',
                    											aParentFieldId=parentFieldId,
                												aParentName=parentName,
                                                    			Id='ActionItemList', 
                												rendered = true,aQueryParams= 'RecordType.Name = \'Action Item\'', 
                												aParentId = objProject.Id,
                                                    			someColumnNames='Description__c,Status__c,Date_Identified__c,Owner__c,Action_Plan__c,Display_on_Status_Report__c',
                                                    			object='Project_Log__c');

            return ActionItemList;
        }
        return null;
    }
    
    //Returns sl_InlineEditList component for Decision record type of Project Log objects if tab is active. Otherwise, returns nothing. 
    public Component.c.sl_InlineEditList getDecisionList() {

        if(tab4.isActive){
            Component.c.sl_InlineEditList DecisionList = new Component.c.sl_InlineEditList(
                													listName='Decisions',
                													rtName='Decision',
                													aParentFieldId=parentFieldId,
                													aParentName=parentName,
                                                    				Id='DecisionList', 
                													rendered = true,
                													aQueryParams= 'RecordType.Name = \'Decision\'', 
                													aParentId = objProject.Id,
                                                    				someColumnNames='Description__c,Status__c,Date_Identified__c,Owner__c,Decision__c,Display_on_Status_Report__c',
                                                    				object='Project_Log__c');
            return DecisionList;
        }
        return null;
    }
    
    //class to represent tabs on the visual force page
	public class componentTab{
        
        public String name {get;set;}
        public boolean isActive {get;set;} 
        
        public componentTab(String name,Boolean isActive){
            this.name = name;
            this.isActive = isActive;
        }
        
    }
}