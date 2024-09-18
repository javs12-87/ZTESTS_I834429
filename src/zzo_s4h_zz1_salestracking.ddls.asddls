/********** GENERATED on 07/19/2022 at 23:44:10 by CB9980000000**************/
 @OData.entitySet.name: 'ZZ1_SalesTracking' 
 @OData.entityType.name: 'ZZ1_SalesTrackingType' 
 define root abstract entity ZZO_S4H_ZZ1_SALESTRACKING { 
 key ID : abap.string( 0 ) ; 
 @Odata.property.valueControl: 'SalesDocument_vc' 
 SalesDocument : abap.char( 10 ) ; 
 SalesDocument_vc : RAP_CP_ODATA_VALUE_CONTROL ; 
 @Odata.property.valueControl: 'SalesDocumentType_vc' 
 SalesDocumentType : abap.char( 4 ) ; 
 SalesDocumentType_vc : RAP_CP_ODATA_VALUE_CONTROL ; 
 @Odata.property.valueControl: 'CreationDate_vc' 
 CreationDate : RAP_CP_ODATA_V2_EDM_DATETIME ; 
 CreationDate_vc : RAP_CP_ODATA_VALUE_CONTROL ; 
 @Odata.property.valueControl: 'LastChangeDate_vc' 
 LastChangeDate : RAP_CP_ODATA_V2_EDM_DATETIME ; 
 LastChangeDate_vc : RAP_CP_ODATA_VALUE_CONTROL ; 
 @Odata.property.valueControl: 'TotalNetAmount_vc' 
 @Semantics.amount.currencyCode: 'TransactionCurrency' 
 TotalNetAmount : abap.curr( 16, 3 ) ; 
 TotalNetAmount_vc : RAP_CP_ODATA_VALUE_CONTROL ; 
 @Odata.property.valueControl: 'TransactionCurrency_vc' 
 @Semantics.currencyCode: true 
 TransactionCurrency : abap.cuky ; 
 TransactionCurrency_vc : RAP_CP_ODATA_VALUE_CONTROL ; 
 @Odata.property.valueControl: 'CalculatedStatus_vc' 
 CalculatedStatus : abap.char( 20 ) ; 
 CalculatedStatus_vc : RAP_CP_ODATA_VALUE_CONTROL ; 
 ETAG__ETAG : abap.string( 0 ) ; 
 
 } 
