# 🛠️ Sistema de Gerenciamento de Manutenção e Inventário Salesforce

## 🔍 Visão Geral

Este projeto Salesforce automatiza o gerenciamento de casos de manutenção e sincroniza o inventário de equipamentos com uma fonte externa. Utiliza Apex para lógica de negócio, chamadas REST assíncronas e testes automatizados para garantir a qualidade e consistência dos dados.

---

## 🚀 Funcionalidades Principais

### 1️⃣ Automação de Casos de Manutenção

- 🧾 Cria automaticamente novos casos do tipo **Routine Maintenance** quando um caso do tipo **Repair** ou **Routine Maintenance** é fechado.
- 🗓️ Calcula a data de vencimento (`Date_Due__c`) do novo caso com base no menor ciclo de manutenção (`Maintenance_Cycle__c`) dos itens associados ao caso fechado.
- 📄 Clona os itens de manutenção relacionados para manter o histórico e garantir rastreabilidade do equipamento.

### 2️⃣ Sincronização de Inventário via REST Callout

- 🔄 Realiza chamada REST assíncrona (via `Queueable`) para um endpoint externo que retorna dados de equipamentos em formato JSON.
- 🧩 Deserializa os dados e os converte para registros do objeto padrão **Product2**, atualizando campos customizados como ciclo de manutenção, custo, SKU, entre outros.
- 🆔 Realiza upsert utilizando o campo externo `Warehouse_SKU__c` para evitar duplicidade e manter o inventário sincronizado.

### 3️⃣ Testes Automatizados

- ✅ Testa a trigger que dispara a lógica quando um caso muda para status **Closed**.
- 🔎 Valida a criação automática dos novos casos, garantindo que os campos e relações estejam corretos.
- 📊 Confirma a lógica de agregação e consulta do menor ciclo de manutenção.
- 🧬 Garante a correta clonagem e atualização dos itens de manutenção para o novo caso.

---

## 🧱 Estrutura do Projeto

| 📁 Arquivo/Classe                 | 📌 Descrição                                                                                     |
| -------------------------------- | ------------------------------------------------------------------------------------------------ |
| `MaintenanceRequestHelper`       | Classe Apex responsável pela lógica de criação e atualização de casos e itens de manutenção.     |
| `MaintenanceRequestHelperTest`   | Classe de teste que cobre as funcionalidades da helper, utilizando dados reais (`seeAllData=true`). |
| `WarehouseCalloutService`        | Classe `Queueable` que realiza callout REST para sincronização assíncrona do inventário com API externa. |

---

## ⚙️ Requisitos

- 🏢 Organização Salesforce com suporte a Apex e permissões para execução de chamadas REST assíncronas.
- 🌐 Endpoint externo configurado e acessível para sincronização do inventário.
- 🧾 Campos customizados criados nos objetos **Case**, **Product2** e **Equipment_Maintenance_Item__c** conforme mapeamento na classe.
- 🔁 Configuração da trigger para chamar a helper no fechamento dos casos (não fornecida, mas necessária para funcionamento automático).

---

## 📦 Como Implantar

1. 📤 Faça o deploy das classes Apex para sua organização Salesforce via Metadata API, Salesforce CLI ou IDE de sua preferência.
2. ✅ Confirme que os campos customizados e objetos necessários estão criados e configurados.
3. 🔄 Garanta que triggers ou processos chamem o método `MaintenanceRequestHelper.createNewCase` sempre que um caso for fechado.
4. 🕒 Para sincronizar o inventário, agende a execução da classe `WarehouseCalloutService` como um job assíncrono (pode ser manual ou via schedulable Apex).

   💻 Exemplo para enfileirar o job manualmente via Anonymous Apex:

   ```apex
   System.enqueueJob(new WarehouseCalloutService());
   ```
---

## Campos Customizados Utilizados (exemplos) 

| 🧩 Objeto                  | 🏷️ Campo                   | 📝 Descriçã                      |
| --------------------------- | -------------------------- | --------------------------------- |
| Case                        | Vehicle__c                 | Referência ao veículo             |
| Case                        | Product__c                 | Produto relacionado               |
| Case                        | Date_Reported__c           | Data de registro do caso          |
| Case                        | Date_Due__c                | Data de vencimento do SLA         |
| Product2                    | Maintenance_Cycle__c       | Ciclo de manutenção em dias       |
| Product2                    | Lifespan_Months__c         | Vida útil do equipamento (meses) |
| Product2                    | Warehouse_SKU__c           | Código SKU para inventário        |
| Product2                    | Replacement_Part__c        | Indica se é peça de reposição     |
| Equipment_Maintenance_Item__c | Maintenance_Request__c    | Lookup para o caso de manutenção  |



---

## ✅ Considerações Finais
Este sistema permite uma gestão mais eficiente dos casos de manutenção e do inventário de equipamentos, reduzindo retrabalho e erros de sincronização. A arquitetura baseada em Apex assíncrono garante desempenho e escalabilidade, enquanto os testes automatizados aumentam a confiabilidade do código.
   
