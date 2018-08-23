@isTest
public class sl_Test_InlineEditListController  {
    
    public static testMethod void intlineEditListControllerTest (){
       
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

		test.startTest();
        
        //new instance of the controller        
        SL_ctrl_InlineEditList decisionController = inlineListCreator('Decision',proj.Id, proj.Name);
        System.assertEquals(decisionController.parentName,proj.Name);

        /******************test list returned by the controller**************/
        
        
        system.assertEquals(decisionController.listObjects.size(),3);
        system.assertEquals(decisionController.listObjects[0].getSObjectType().getDescribe().getName(), 'Project_Log__c');
        
        
        /******************Make sure the columns are coming back wrapped*****/
        
        List<SL_ctrl_InlineEditList.ColumnWrapper> wrappedColumns = decisionController.wrappedColumns;
        List<String> listColumnNames = decisionController.columnNames.replace(' ','').split(',');
        
        for(SL_ctrl_InlineEditList.ColumnWrapper wrappedColumn: wrappedColumns){
            
            system.assert(listColumnNames.contains(wrappedColumn.FieldName));
                
        }
        
        //new instance of the controller for action item
        SL_ctrl_InlineEditList actionItemController = inlineListCreator('Action Item', Proj.Id, proj.Name);

        /******************test the update by controller*********************/
        
        system.assert(actionItemController.listObjects.size() == 3);
        
        Map<String,Schema.sObjectField> mapProjLogField = Schema.getGlobalDescribe().get('Project_Log__c').getDescribe().fields.getMap();
        //update each project log that was queried
        actionItemController.listObjects[0].put(mapProjLogField.get('Status__c'),'Closed');
        actionItemController.listObjects[1].put(mapProjLogField.get('Action_Plan__c'),'We have a better plan');
        actionItemController.listObjects[2].put(mapProjLogField.get('Display_on_Status_Report__c'),False);
        
        //save and verify
        actionItemController.doSave();
        List<Project_Log__c> listTestObjects = actionItemController.listObjects;
        
        for(Project_Log__c objLog : listTestObjects){
        
            System.assert(objLog.Status__c == 'Closed' || objLog.Action_Plan__c == 'We have a better plan' || objLog.Display_on_Status_Report__c == False);
            
        } 
        
        //Exercise error in save
        
        
        actionItemController.listObjects[1].put(mapProjLogField.get('Status__c'),null);
        actionItemController.doSave();
        
        /**********************Test the Cancel of updates*****************************/
        
        List<Project_Log__c> listIssueLogs = [Select Id
                                               ,Issue_Severity__c
                                               ,Issue_Type__c 
                                               ,Display_on_Status_Report__c
                                               From Project_Log__c
                                               Where RecordTypeId =: issueRT];

        
        //rather than evaluating to determine the list is the right size, let's just assert.
        system.assert(listIssueLogs.size() == 3);
        
          //new instance of the controller for action item
        SL_ctrl_InlineEditList issueController = inlineListCreator('Issue', Proj.Id, proj.Name);
		issueController.recordTypeName = 'Issue';
        /******************test the update by controller*********************/
        
        system.assert(listTestObjects.size() == 3);
        
        //update each project log that was queried
        issueController.listObjects[0].put(mapProjLogField.get('Issue_Severity__c'),'High');
        issueController.listObjects[1].put(mapProjLogField.get('Issue_Type__c'),'Not Business');
        issueController.listObjects[2].put(mapProjLogField.get('Display_on_Status_Report__c'),False);
        
        listIssueLogs = issueController.listObjects;
      
        //cancel and verify
        issueController.doCancel();
        
        listIssueLogs = [Select Id
                         ,Issue_Severity__c
                         ,Issue_Type__c 
                         ,Display_on_Status_Report__c
                         From Project_Log__c
                         Where RecordTypeId =: issueRT];
        
        for(Project_Log__c objLog : listIssueLogs){
        
            System.assert(objLog.Issue_Severity__c == 'Medium' || objLog.Issue_Type__c == 'Business' || objLog.Display_on_Status_Report__c == TRUE);
			System.assertEquals(issueController.recordTypeId, string.valueOf(issueRT) );
            
        }
        
        system.debug(issueController.pendingChanges);
        //*********************Let's test the delete!!!******************************//
        
        SL_ctrl_InlineEditList riskController = inlineListCreator('Risk', Proj.Id, proj.Name);
		riskController.actionRow = 1;
        riskController.doDelete();
        
        System.assertEquals([Select Id from Project_Log__c where RecordTypeId =: riskRT].size() , 2);

        
        test.stopTest();
    }
    
    
    private static SL_ctrl_InlineEditList inlineListCreator(String recordType, Id projId,String projName){
        
        //new instance of the controller        
        SL_ctrl_InlineEditList controller = new SL_ctrl_InlineEditList();

        /******************test list returned by the controller**************/
        
        controller.columnNames = 'Description__c,Status__c,Date_Identified__c,Issue_Severity__c,Issue_Type__c,Owner__c,Display_on_Status_Report__c,Risk_Event__c,Risk_Score__c,Action_Plan__c,Decision__c';
        controller.queryParams = ' RecordType.Name = \''  + recordType + '\'';
        controller.parentId = projId;
        controller.sObjectType = 'Project_Log__c';
        controller.parentName = projName;
        return controller;
        
    }
            
}