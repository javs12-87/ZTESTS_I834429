@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '5S2F - Registration'
define root view entity z5s2f_reg_view as select from z5s2f_reg
{
    key guid as Guid,
    firstname as Firstname,
    lastname as Lastname,
    email as Email,
    companyname as Companyname,
    erpnumber as Erpnumber,
    region as Region,
    agree as Agree,
    basis_firstname as BasisFirstname,
    basis_lastname as BasisLastname,
    basis_email as BasisEmail,
    functional_firstname as FunctionalFirstname,
    functional_lastname as FunctionalLastname,
    functional_email as FunctionalEmail,
    developer_firstname as DeveloperFirstname,
    developer_lastname as DeveloperLastname,
    developer_email as DeveloperEmail,
    analytics_firstname as AnalyticsFirstname,
    analytics_lastname as AnalyticsLastname,
    analytics_email as AnalyticsEmail,
    security_firstname as SecurityFirstname,
    security_lastname as SecurityLastname,
    security_email as SecurityEmail,
    teamlead_firstname as TeamleadFirstname,
    teamlead_lastname as TeamleadLastname,
    teamlead_email as TeamleadEmail
    
}
