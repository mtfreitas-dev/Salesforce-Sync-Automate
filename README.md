# Sistema de Gerenciamento de Manutenção e Inventário Salesforce

## Visão Geral

Este projeto Salesforce automatiza o gerenciamento de casos de manutenção e sincroniza o inventário de equipamentos com uma fonte externa. Utiliza Apex para lógica de negócio, chamadas REST assíncronas e testes automatizados para garantir a qualidade e consistência dos dados.

---

## Funcionalidades Principais

### 1. Automação de Casos de Manutenção
- Cria automaticamente novos casos do tipo **Routine Maintenance** quando um caso do tipo **Repair** ou **Routine Maintenance** é fechado.
- Calcula a data de vencimento (`Date_Due__c`) do novo caso com base no menor ciclo de manutenção (`Maintenance_Cycle__c`) dos itens associados ao caso fechado.
- Clona os itens de manutenção relacionados para manter o histórico e garantir rastreabilidade do equipamento.

### 2. Sincronização de Inventário via REST Callout
- Realiza chamada REST assíncrona (via `Queueable`) para um endpoint externo que retorna dados de equipamentos em formato JSON.
- Deserializa os dados e os converte para registros do objeto padrão **Product2**, atualizando campos customizados como ciclo de manutenção, custo, SKU, entre outros.
- Realiza upsert utilizando o campo externo `Warehouse_SKU__c` para evitar duplicidade e manter o inventário sincronizado.

### 3. Testes Automatizados
- Testa a trigger que dispara a lógica quando um caso muda para status **Closed**.
- Valida a criação automática dos novos casos, garantindo que os campos e relações estejam corretos.
- Confirma a lógica de agregação e consulta do menor ciclo de manutenção.
- Garante a correta clonagem e atualização dos itens de manutenção para o novo caso.

---

## Estrutura do Projeto

| Arquivo/Classe                  | Descrição                                                      |
| ------------------------------ | -------------------------------------------------------------- |
| `MaintenanceRequestHelper`      | Classe Apex responsável pela lógica de criação e atualização de casos e itens de manutenção. |
| `MaintenanceRequestHelperTest`  | Classe de teste que cobre as funcionalidades da helper, utilizando dados reais (`seeAllData=true`). |
| `WarehouseCalloutService`       | Classe `Queueable` que realiza callout REST para sincronização assíncrona do inventário com API externa. |

---

## Requisitos

- Organização Salesforce com suporte a Apex e permissões para execução de chamadas REST assíncronas.
- Endpoint externo configurado e acessível para sincronização do inventário.
- Campos customizados criados nos objetos **Case**, **Product2** e **Equipment_Maintenance_Item__c** conforme mapeamento na classe.
- Configuração da trigger para chamar a helper no fechamento dos casos (não fornecida, mas necessária para funcionamento automático).

---

## Como Implantar

1. Faça o deploy das classes Apex para sua organização Salesforce via Metadata API, Salesforce CLI ou IDE de sua preferência.
2. Confirme que os campos customizados e objetos necessários estão criados e configurados.
3. Garanta que triggers ou processos chamem o método `MaintenanceRequestHelper.createNewCase` sempre que um caso for fechado.
4. Para sincronizar o inventário, agende a execução da classe `WarehouseCalloutService` como um job assíncrono (pode ser manual ou via schedulable Apex).
   
   Exemplo para enfileirar o job manualmente via Anonymous Apex:
   ```apex
   System.enqueueJob(new WarehouseCalloutService());
