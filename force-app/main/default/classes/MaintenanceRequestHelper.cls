public without sharing class MaintenanceRequestHelper {

    public static void createNewCase(Map<Id, Case> newMap){
        //Map que armazena como chave o Id do caso que recebeu o status como 'Close' e o valor o case que irá ser criado
        //Map that stores as key the ID of the case that received the status as 'Close' and the value of the case that will be created
        Map<Id, Case> newCaseList = new Map<Id, Case>();

        //Popula o map conforme descrito anteriormente
        //Population map as described previously
        for(Case cc : newMap.values()){
            if(cc.Type == 'Repair' || cc.Type == 'Routine Maintenance' && cc.status == 'Closed'){
                newCaseList.put(cc.Id, new Case(
                    Vehicle__c = cc.Vehicle__c, Product__c = cc.Product__c, Type = 'Routine Maintenance', Subject = ' Vistoria de manutenção do veiculo ', Status = 'New', Origin = 'Email',
                    Date_Reported__c = System.TODAY()
                ));
            }
        }


        List<sObject> minDueDate = getMinMaintenanceCycle(newMap.keySet());
                
        for(sObject s : minDueDate){
            String caseId = (String)s.get('Maintenance_Request__c');
            Decimal minDay = (Decimal)s.get('minDay');
            Integer aux = (Integer) minDay;
            System.debug('minDay ' + minDay);
            
            for(Id cc2 : newCaseList.keySet()){
                if(cc2 == caseId){                  
                    newCaseList.get(caseId).Date_Due__c = System.Today() + aux;
                    System.debug('Campo de data ' +  newCaseList.get(caseId).Date_Due__c);
                }
            }
        }

        if(newCaseList.size() > 0){
                insert newCaseList.values();
        }

        updateEquipmentMaintenanceItemRecord(newCaseList);
    }

    //Retorna uma lista contendo uma sumarização do campo Maintenance_Cycle__c de acordo com as ID do caso
    //Returns a list containing a summary of the Maintenance_Cycle__c field according to the case ID
    public static List<sObject> getMinMaintenanceCycle(Set<Id> caseIds){
        return [SELECT MIN(Equipment__r.Maintenance_Cycle__c) minDay, Maintenance_Request__c FROM Equipment_Maintenance_Item__c WHERE Maintenance_Request__c IN:caseIds GROUP BY Maintenance_Request__c];
    }

    public static void updateEquipmentMaintenanceItemRecord(Map<Id,Case> mapCases){

        //Método recebe um map onde as chaves são os Ids das listas que receberam o status 'Closed' e seus valores são os novos casos criados a partir da Trigger
        //Method receives a map where the keys are the IDs of the lists that received the 'Closed' status and their values are the new cases created from the Trigger

        //Realiza uma Query no objeto de Items de Manutenção de Equipamento e que tenham como parent o ID dos casos que receberam o status 'Closed'
        //Performs a Query on the Equipment Maintenance Items object that has as parent the ID of the cases that received the status 'Closed'
        List<Equipment_Maintenance_Item__c> oldEmiList = [SELECT Id,Equipment__c,Maintenance_Request__c FROM Equipment_Maintenance_Item__c WHERE Maintenance_Request__c IN:mapCases.keySet()];

        
        //Realiza um clone da lista de EMI antigos, para depois inserir na Database
        //Creates a clone of the old EMI list, to then insert it into the Database
        List<Equipment_Maintenance_Item__c> newEmiList = oldEmiList.deepClone();

        //Atualiza o campo Maintenance Request da lista clonada com o Id do caso que foi criado. Para isso utiliza o map que possui o Id da caso 'close' que possui o valor do Id do caso criado. 
        //Updates the Maintenance Request field of the cloned list with the ID of the case that was created. To do this, use the map that has the ID of the 'close' case, which has the value of the ID of the created case.
        for(Equipment_Maintenance_Item__c newEmi : newEmiList){
            newEmi.Maintenance_Request__c = mapCases.get(newEmi.Maintenance_Request__c).Id;
        }

        System.debug('Lista de itens de equipamentos ' + newEmiList);
        insert newEmiList;
    }
}