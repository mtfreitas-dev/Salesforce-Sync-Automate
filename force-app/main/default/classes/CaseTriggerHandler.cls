public without sharing class CaseTriggerHandler {

    //Armazena os valores que serão manipulados
    //Stores the values ​​that will be manipulated

    List<Case> oldRecords {get;set;}
    List<Case> newRecords {get;set;}
    Map<Id, Case> oldMap {get; set;}
    Map<Id, Case> newMap {get; set;}

    public CaseTriggerHandler(List<Case> oldRecords, List<Case> newRecords, Map<Id, Case> oldMap, Map<Id, Case> newMap) {
        this.oldRecords = oldRecords;
        this.newRecords = newRecords;
        this.oldMap = oldMap;
        this.newMap = newMap;
    }

    //Este método aciona outras funções quando a trigger na condição afterUpdate é acionada
    //This method triggers other functions when the trigger in the afterUpdate condition is triggered

    public void afterUpdate(){
        List<Case> caseList = MaintenanceRequestHelper.checkStatusCase(this.newMap);
        try{
            insert caseList;
        } catch(Exception e){
            System.debug('Ocorreu um erro ao inserir os novos casos ' + e.getMessage());
        }

        List<Equipment_Maintenance_Item__c> equipmentList = MaintenanceRequestHelper.createNewEquipment(caseList, this.newMap);
        try{
            insert equipmentList;
        } catch(Exception e){
            System.debug('Ocorreu um erro ao inserir os novos casos ' + e.getMessage());
        } 

        MaintenanceRequestHelper.calcDateDue(caseList, equipmentList);
    }
}
