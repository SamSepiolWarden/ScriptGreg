set-DynamicDistributionGroup -identity "_consulting-all" -RecipientFilter "(Department -like 'Consulting*') -and (RecipientType -eq 'UserMailbox')"
set-DynamicDistributionGroup -identity "_consulting-onlycsm" -RecipientFilter "(Department -eq 'Consulting-CSM') -and (RecipientType -eq 'UserMailbox')"
set-DynamicDistributionGroup -identity "_consulting-onlycsta" -RecipientFilter "(Department -eq 'Consulting-CSTA') -and (RecipientType -eq 'UserMailbox')"
set-DynamicDistributionGroup -identity "_consulting-onlymanager" -RecipientFilter "(Department -eq 'Consulting-Manager') -and (RecipientType -eq 'UserMailbox')"


set-DynamicDistributionGroup -identity "_sales-all" -RecipientFilter "(Department -like 'Sales*') -and (RecipientType -eq 'UserMailbox')"
set-DynamicDistributionGroup -identity "_sales-onlyManager" -RecipientFilter "(Department -like 'Sales-Manager') -and (RecipientType -eq 'UserMailbox')"

set-DynamicDistributionGroup -identity "_sales-onlysalesEx" -RecipientFilter "(Department -like 'Sales-SalesEx*') -and (RecipientType -eq 'UserMailbox')"
set-DynamicDistributionGroup -identity "_sales-onlySalesExFrance" -RecipientFilter "(Department -eq 'Sales-SalesEx-France') -and (RecipientType -eq 'UserMailbox')"
set-DynamicDistributionGroup -identity "_sales-onlySalesExAPAC" -RecipientFilter "(Department -eq 'Sales-SalesEx-APAC') -and (RecipientType -eq 'UserMailbox')"
set-DynamicDistributionGroup -identity "_sales-onlySalesExIntl" -RecipientFilter "(Department -eq 'Sales-SalesEx-Intl') -and (RecipientType -eq 'UserMailbox')"

set-DynamicDistributionGroup -identity "_sales-onlysdr" -RecipientFilter "(Department -like 'Sales-Sdr*') -and (RecipientType -eq 'UserMailbox')"
set-DynamicDistributionGroup -identity "_sales-onlySdrFrance" -RecipientFilter "(Department -eq 'Sales-Sdr-France') -and (RecipientType -eq 'UserMailbox')"
set-DynamicDistributionGroup -identity "_sales-onlySdrAPAC" -RecipientFilter "(Department -eq 'Sales-Sdr-APAC') -and (RecipientType -eq 'UserMailbox')"
set-DynamicDistributionGroup -identity "_sales-onlySdrIntl" -RecipientFilter "(Department -eq 'Sales-Sdr-Intl') -and (RecipientType -eq 'UserMailbox')"
set-DynamicDistributionGroup -identity "_sales-onlySdrManager" -RecipientFilter "(Department -eq 'Sales-Sdr-Manager') -and (RecipientType -eq 'UserMailbox')"


set-DynamicDistributionGroup -identity "_operations-All" -RecipientFilter "(Department -like 'Operations*') -and (RecipientType -eq 'UserMailbox')"

set-DynamicDistributionGroup -identity "_operations-OnlyIT" -RecipientFilter "(Department -like 'Operations-IT*') -and (RecipientType -eq 'UserMailbox')"
set-DynamicDistributionGroup -identity "_operations-OnlyITSystem" -RecipientFilter "(Department -like 'Operations-IT-System') -and (RecipientType -eq 'UserMailbox')"
set-DynamicDistributionGroup -identity "_operations-OnlyDsiWebsite" -RecipientFilter "(Department -like 'Operations-IT-WebSite') -and (RecipientType -eq 'UserMailbox')"

set-DynamicDistributionGroup -identity "_operations-OnlyHR" -RecipientFilter "(Department -eq 'Operations-HR') -and (RecipientType -eq 'UserMailbox')"
set-DynamicDistributionGroup -identity "_operations-OnlyFinance" -RecipientFilter "(Department -eq 'Operations-Finance') -and (RecipientType -eq 'UserMailbox')"
set-DynamicDistributionGroup -identity "_operations-OnlyLegal" -RecipientFilter "(Department -eq 'Operations-Legal') -and (RecipientType -eq 'UserMailbox')"


set-DynamicDistributionGroup -identity "_marketing-All" -RecipientFilter "(Department -like 'Marketing*') -and (RecipientType -eq 'UserMailbox')"

set-DynamicDistributionGroup -identity "_marketing-OnlyMarketing" -RecipientFilter "(Department -eq 'Marketing-Marketing') -and (RecipientType -eq 'UserMailbox')"
set-DynamicDistributionGroup -identity "_marketing-OnlyDesign" -RecipientFilter "(Department -eq 'Marketing-Design') -and (RecipientType -eq 'UserMailbox')"
set-DynamicDistributionGroup -identity "_marketing-OnlyPartnerships" -RecipientFilter "(Department -eq 'Marketing-Partnerships') -and (RecipientType -eq 'UserMailbox')"
set-DynamicDistributionGroup -identity "_marketing-OnlyManager" -RecipientFilter "(Department -eq 'Marketing-Manager') -and (RecipientType -eq 'UserMailbox')"


set-DynamicDistributionGroup -identity "_product-All" -RecipientFilter "(Department -like 'Product*') -and (RecipientType -eq 'UserMailbox')"
set-DynamicDistributionGroup -identity "_product-OnlyRnD" -RecipientFilter "(Department -eq 'Product-RnD') -and (RecipientType -eq 'UserMailbox')"
set-DynamicDistributionGroup -identity "_product-OnlyClientSupport" -RecipientFilter "(Department -eq 'Product-ClientSupport') -and (RecipientType -eq 'UserMailbox')"
set-DynamicDistributionGroup -identity "_product-OnlyProductManager" -RecipientFilter "(Department -eq 'Product-ProductManager') -and (RecipientType -eq 'UserMailbox')"
set-DynamicDistributionGroup -identity "_product-OnlyQA" -RecipientFilter "(Department -eq 'Product-QA') -and (RecipientType -eq 'UserMailbox')"
set-DynamicDistributionGroup -identity "_product-OnlySSI" -RecipientFilter "(Department -eq 'Product-SSI') -and (RecipientType -eq 'UserMailbox')"

