@isTest
public class SL_Test_ctrl_ProjetLogList {

         public static testMethod void projectLogListTest (){ 
        //build test data for Projects and Project Logs     
        
        pse__Proj__c proj = new pse__Proj__c();
        proj.Name = 'TEST';
        proj.JIRA_Project_Name__c = 'TEST';
        proj.pse__Is_Active__c = true;
        proj.pse__Is_Billable__c = true;
        proj.pse__Allow_Timecards_Without_Assignment__c = true;
        
        insert proj;

        Id actionItemRT = Schema.SObjectType.Project_Log__c.getRecordTypeInfosByName().get('Action Item').getRecordTypeId();
        Id decisionRT = Schema.SObjectType.Project_Log__c.getRecordTypeInfosByName().get('Decision').getRecordTypeId();
        Id issueRT = Schema.SObjectType.Project_Log__c.getRecordTypeInfosByName().get('Issue').getRecordTypeId();
        Id riskRT = Schema.SObjectType.Project_Log__c.getRecordTypeInfosByName().get('Risk').getRecordTypeId();
        
        Map<String,Id> mapProjectLogRT = new Map<String,Id>();
        mapProjectLogRT.put('Action Item',actionItemRT);
        mapProjectLogRT.put('Decision',decisionRT);
        mapProjectLogRT.put('Issue', issueRT);
        mapProjectLogRT.put('Risk', riskRT);
        
        List<Project_Log__c> listProjectLogs = new List<Project_Log__c>();
        
        for(integer i = 0; i <3; i++){
            for(integer j = 0; j <4; j++){
                Project_Log__c objLog = new Project_Log__c(
                    Project__c = proj.id,
                    RecordTypeId = mapProjectLogRT.values()[j],
                    Status__c = 'Open',
                    Date_Identified__c = Date.today(),
                    Display_on_Status_Report__c = true,
                    Description__c = 'Description'
                );
                if(mapProjectLogRT.values()[j] == issueRT){
                    objLog.Issue_Severity__c = 'Medium'; 
                    objLog.Issue_Type__c = 'Business';
                    objLog.Display_on_Status_Report__c = true;
                }
                if(mapProjectLogRT.values()[j] == riskRT){
                    objLog.Risk_Event__c = 'Some risk event';
                    objLog.Risk_Impact__c = '1';
                    objLog.Risk_Likelihood__c = '1';
                }
                if(mapProjectLogRT.values()[j] == actionItemRT){
                    objLog.Action_Plan__c = 'We have some action planned';
                }
                if(mapProjectLogRT.values()[j] == decisionRT){
                    objLog.Decision__c = 'Here is our dicision';
                }
                listProjectLogs.add(objLog);
            }
        }

        if(!listProjectLogs.isEmpty()){
            insert listProjectLogs;
        }
        ApexPages.StandardController stdController = new ApexPages.StandardController(proj);
        SL_ctrl_ProjectLogList controller = new SL_ctrl_ProjectLogList(stdController);
             
        test.startTest();
             
        controller.currentTab = 'tab1';     
        controller.switchTabs();

                
        System.assertEquals(controller.tab2.isActive, false);
        System.assertEquals(controller.tab3.isActive, false);     
    	System.assertEquals(controller.tab4.isActive, false);
             
		Component.c.sl_InlineEditList issuesList = controller.getIssuesList();     
        Component.c.sl_InlineEditList riskList = controller.getRiskList();
        Component.c.sl_InlineEditList actionItemList = controller.getActionItemList();
        Component.c.sl_InlineEditList decisionList = controller.getDecisionList();
        
        System.assertEquals(decisionList, null);
        System.assertEquals(riskList, null);
		System.assertEquals(actionItemList, null);
        System.assert(issuesList != null);
		
		controller.currentTab = 'tab2';     
        controller.switchTabs();

             
		issuesList = controller.getIssuesList();     
        riskList = controller.getRiskList();
        actionItemList = controller.getActionItemList();
        decisionList = controller.getDecisionList();
        
        System.assertEquals(decisionList, null);
        System.assertEquals(issuesList, null);
		System.assertEquals(actionItemList, null);
        System.assert(riskList != null);
		
				
		controller.currentTab = 'tab3';     
        controller.switchTabs();

             
		issuesList = controller.getIssuesList();     
        riskList = controller.getRiskList();
        actionItemList = controller.getActionItemList();
        decisionList = controller.getDecisionList();
        
        System.assertEquals(decisionList, null);
        System.assertEquals(issuesList, null);
		System.assertEquals(riskList, null);
        System.assert(actionItemList != null);                          
		
				
		controller.currentTab = 'tab4';     
        controller.switchTabs();

             
		issuesList = controller.getIssuesList();     
        riskList = controller.getRiskList();
        actionItemList = controller.getActionItemList();
        decisionList = controller.getDecisionList();
        
        System.assertEquals(actionItemList, null);
        System.assertEquals(issuesList, null);
		System.assertEquals(riskList, null);
        System.assert(decisionList != null);                          
        test.stopTest();
             
	}
    
}