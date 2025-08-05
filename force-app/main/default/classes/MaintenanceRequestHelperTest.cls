@isTest(seeAllData=true)
public with sharing class MaintenanceRequestHelperTest {

    // 🔧 Testa a execução da trigger ao atualizar o status do caso para "Closed"
    // Tests trigger execution when a case status is updated to "Closed"
    @isTest static void testeTrigger() {
        // Simula a criação de um caso e altera seu status
        // Simulates case creation and status update
        Case cc = new Case(
            vehicle__c = 'a02ak000003HOgzAAG',
            Product__c = '01tak000008bN4HAAU',
            Type = 'Routine Maintenance',
            Subject = ' Vistoria de manutenção do veiculo ',
            Status = 'New',
            Origin = 'Email',
            Date_Reported__c = System.TODAY()
        );
        insert cc;

        Test.startTest();
        cc.Status = 'Closed';
        Database.SaveResult result = Database.update(cc, false);
        Test.stopTest();

        // ✅ Verifica se a atualização do status foi bem-sucedida
        // Validates if the status update was successful
        System.Assert(result.isSuccess());
    }

    // 🧪 Testa a criação de um novo caso de manutenção com base em um caso fechado
    // Tests creation of a new maintenance case based on a closed case
    @isTest static void testeCreateNewCase() {
        // Pré-condição: caso fechado e item de manutenção existente
        // Pre-condition: closed case and existing maintenance item
        Product2 product = [SELECT Id, Maintenance_Cycle__c FROM Product2 WHERE Id = '01tak000008beWZAAY'];
        
        Case closedCase = new Case(
            vehicle__c = 'a02ak000003HOgzAAG',
            Product__c = '01tak000008bN4HAAU',
            Type = 'Routine Maintenance',
            Subject = ' Vistoria de manutenção do veiculo ',
            Status = 'Closed',
            Origin = 'Email',
            Date_Reported__c = System.TODAY(),
            ProductId = product.Id
        );
        insert closedCase;

        Equipment_Maintenance_Item__c emiTest = new Equipment_Maintenance_Item__c(
            Equipment__c = product.Id,
            Maintenance_Request__c = closedCase.Id
        );
        insert emiTest;

        // 🛠️ Executa a lógica principal da classe helper
        // Executes the core helper logic
        Map<Id, Case> closedMapCase = new Map<Id, Case>{ closedCase.Id => closedCase };
        Test.startTest();
        MaintenanceRequestHelper.createNewCase(closedMapCase);
        Test.stopTest();

        // ✅ Valida se o novo caso foi criado com os dados esperados
        // Validates whether the new case was created with the correct data
        List<Case> lstCasos = [
            SELECT Id, Date_Due__c, Status, Type
            FROM Case
            WHERE Status = 'New' AND Vehicle__c = :closedMapCase.get(closedCase.Id).Vehicle__c
        ];

        System.assert(lstCasos.size() > 0);
        for(Case cc : lstCasos){
            System.assertEquals('Routine Maintenance', cc.Type);
            System.assertEquals('New', cc.Status);
            System.assertEquals(System.TODAY().addDays((Integer) product.Maintenance_Cycle__c), cc.Date_Due__c);
        }
    }

    // 📊 Testa o método de agregação de ciclo de manutenção mínimo
    // Tests the method that calculates the minimum maintenance cycle
    @isTest static void testGetMinMaintenanceCycle() {
        Vehicle__c newCar = new Vehicle__c(Name = 'Carro Teste');
        insert newCar;

        Case newCase = new Case(
            Status = 'New',
            Type = 'Routine Maintenance',
            Vehicle__c = newCar.Id,
            Origin = 'Email'
        );
        insert newCase;

        Equipment_Maintenance_Item__c newEmi = new Equipment_Maintenance_Item__c(
            Maintenance_Request__c = newCase.Id
        );
        insert newEmi;

        // ✅ Verifica se o método retorna o ID do caso com o menor ciclo
        // Validates that the method returns the case ID with the minimum cycle
        Set<Id> idSet = new Set<Id>{ newCase.Id };
        List<SObject> results = MaintenanceRequestHelper.getMinMaintenanceCycle(idSet);

        System.Assert.areEqual(1, results.size());
    }

    // 🔁 Testa a clonagem dos registros de manutenção para o novo caso
    // Tests the cloning of maintenance item records to the new case
    @isTest static void testupdateEquipmentMaintenanceItemRecord() {
        // Cria dois casos: um fechado (origem) e um novo (destino)
        // Creates two cases: one closed (source) and one new (target)
        Case oldCase = new Case(
            Status = 'Closed',
            Type = 'Routine Maintenance',
            Origin = 'Phone'
        );
        insert oldCase;

        Equipment_Maintenance_Item__c newEmi = new Equipment_Maintenance_Item__c(
            Maintenance_Request__c = oldCase.Id
        );
        insert newEmi;

        Case newCase = new Case(
            Status = 'New',
            Type = 'Routine Maintenance',
            Origin = 'Email'
        );
        insert newCase;

        // 🛠️ Executa a atualização de vínculo dos itens com o novo caso
        // Executes the update to link maintenance items to the new case
        Map<Id, Case> mapIdCase = new Map<Id, Case>{ oldCase.Id => newCase };

        Test.startTest();
        MaintenanceRequestHelper.updateEquipmentMaintenanceItemRecord(mapIdCase);
        Test.stopTest();

        // ✅ Valida se os novos itens estão corretamente associados ao novo caso
        // Validates that new items are correctly associated with the new case
        List<Equipment_Maintenance_Item__c> newEmis = [
            SELECT Name, Maintenance_Request__c
            FROM Equipment_Maintenance_Item__c
            WHERE Maintenance_Request__c = :newCase.Id
        ];

        System.assert(newEmis.size() > 0);
        System.assertEquals(newCase.Id, newEmis[0].Maintenance_Request__c);
    }
}
