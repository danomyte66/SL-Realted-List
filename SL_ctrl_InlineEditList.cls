/*Class: sl_InlineEditListController
 *By: Dane Kim
 *On: 5/3/2018 
 *Purpose: Controller for sl_InlineEditList component. Provides data for custom related list, as well as save and delete actions.
*/

public with sharing class SL_ctrl_InlineEditList  {

    public String sObjectType {get; set;}
    public Id parentId {get; set;}
    public String queryParams {get; set;}
    public List<String> listColumnNames {get; set;}
    public Integer currentPage {get; set;}
    public Integer actionRow {get; set;}
    public String parentLookupFieldId {get;set;}
    public String parentName{get;set;}
    public String recordTypeName{get;set;}
    public Boolean initialized = false;
    public Boolean pendingChanges{
        get{
            if(initialized){
                if(listStore != listObjects){
					system.debug('returning TRUE');
                    return false;
                }
            }
            system.debug('returning FALSE');
            return true;
        }
    }
    public List<sObject> listStore{
        get;     
        set;}
    
       //queries the record set and pass to component
    public List<sObject> listObjects {
        get {
            if(!initialized){
                 String queryString = 'Select ' + columnNames + ' from ' + sObjectType  + ' where Project__c = \'' + parentId + '\'';
                 if(String.isNotBlank(queryParams))  queryString += ' and ' + queryParams;
                 this.listStore = database.query(queryString);
                 this.initialized = true;
            }
			return listStore;
        }
        set;
    }
    
    Public SL_ctrl_InlineEditList(){
        
        this.actionRow = 0;
        this.currentPage = 1;
    }

    public String recordTypeId {
        get{
            if(this.recordTypeName != null){
                try{
                   return Schema.getGlobalDescribe().get(this.sObjectType).getDescribe().getRecordTypeInfosByName().get(this.recordTypeName).getRecordTypeId();
                }
                catch(System.Exception e){
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'Could not retrieve record type')); 
                }
            }
            return '';
        }
    }
    
    //return prefix of parent object for URL hack for new record
    public String objectPrefix {
        get{
            return Schema.getGlobalDescribe().get(this.sObjectType).getDescribe().getKeyPrefix();
        }
    }
    
    //building list of column names for query and for table header
    public string columnNames {get; 
        set{
            this.columnNames = value;
            this.listColumnNames = value.replaceAll('\\s+','').split(',');
        }
    }
    

    
    //Create a list of Column Wrappers which hold field info
    public List<ColumnWrapper> wrappedColumns{
        get {
            
            List<ColumnWrapper> listWrappedColumns = new List<ColumnWrapper>();
            //get map of field labels vs names
            Map<String,Schema.SObjectField> mapFieldInfo = Schema.getGlobalDescribe().get(sObjectType).getDescribe().fields.getMap();

            for(String fieldName: listColumnNames){
                
                if(mapFieldInfo.containsKey(fieldName)){
                    listWrappedColumns.add( new SL_ctrl_InlineEditList.ColumnWrapper(  
                                            fieldName, 
                                            mapFieldInfo.get(fieldName).getDescribe().getLabel(),
                                            mapFieldInfo.get(fieldName).getDescribe().isUpdateable(),
                                            TRUE 
                                            ));
                }                   
            }
            return listWrappedColumns;
        }
        set;
    }
    
    //Saves from the related list command button.
    public void doSave(){
        
        try{
            update listObjects;    
        }
        catch(System.DmlException e){
               
            for (Integer i = 0; i < e.getNumDml(); i++) 
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,e.getDmlMessage(i))); 
            }
        }
    }
    
    public void doDelete(){

        try{
            //delete record
            delete listObjects[actionRow-1];
            //remove from list/table
            listObjects.remove(actionRow-1);
        }
        catch(System.DmlException e){
               
            for (Integer i = 0; i < e.getNumDml(); i++) 
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,e.getDmlMessage(i))); 
            }
        }
    }

    public void doCancel(){
        
        listObjects = this.listObjects;
    }
    public class ColumnWrapper{
        
        public String FieldName {get; set;}
        public String FieldLabel {get; set;}
        public Boolean IsEditable {get; set;}
        public Boolean IsObjField {get; set;}
        
        public ColumnWrapper(String FieldName, String FieldLabel, Boolean IsEditable, Boolean IsObjField) {
            this.FieldName = FieldName; 
            this.FieldLabel = FieldLabel;
            this.IsEditable = IsEditable;
            this.IsObjField = IsObjField;
        }
    }
}