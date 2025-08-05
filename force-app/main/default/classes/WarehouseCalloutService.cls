global with sharing class WarehouseCalloutService implements Queueable, Database.AllowsCallouts {

    // 📦 Classe interna usada como modelo para deserializar os dados do JSON da API externa
    // Inner class used to deserialize JSON data from the external API
    private class EquipmentWrapper {
        public String id { get; set; }
        public Boolean replacement { get; set; }
        public String quantity { get; set; }
        public String name { get; set; }
        public Integer maintenanceperiod { get; set; }
        public Integer lifespan { get; set; }
        public Decimal cost { get; set; }
        public String sku { get; set; }
    }

    // 🚀 Método principal executado de forma assíncrona com Queueable
    // Main method executed asynchronously using Queueable interface
    global static void execute(QueueableContext context){
       
        // 🌐 Realiza um callout GET para um endpoint externo que retorna dados de equipamentos
        // Performs a GET callout to an external endpoint that returns equipment data
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('https://th-superbadge-apex.herokuapp.com/equipment');
        request.setMethod('GET');
        HttpResponse response = http.send(request);

        // 🔄 Converte o JSON retornado para uma lista de objetos do tipo EquipmentWrapper
        // Converts the JSON response into a list of EquipmentWrapper objects
        List<EquipmentWrapper> equipmentList = (List<EquipmentWrapper>) JSON.deserialize(response.getBody(), List<EquipmentWrapper>.class);

        List<Product2> productList = new List<Product2>();

        // 🧱 Mapeia cada item recebido da API para um registro do objeto Product2
        // Maps each item from the API to a Product2 record
        for(EquipmentWrapper equipment : equipmentList){
            productList.add(new Product2(
                Id = equipment.id,
                Replacement_Part__c = equipment.replacement,
                QuantityUnitOfMeasure = equipment.quantity,
                Name = equipment.name,
                Maintenance_Cycle__c = equipment.maintenanceperiod,
                Lifespan_Months__c = equipment.lifespan,
                Cost__c = equipment.cost,
                Warehouse_SKU__c = equipment.sku
            ));
        }

        System.debug('Lista de produtos ' + productList);

        // 📥 Realiza upsert na base de dados utilizando Warehouse_SKU__c como campo externo
        // Performs upsert operation using Warehouse_SKU__c as external ID
        upsert productList Warehouse_SKU__c;

        System.debug('Realizada a atualização do inventário');
    }
}
