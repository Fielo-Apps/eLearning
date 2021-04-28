public with sharing class BackendFooterController {
	public String cExternalJS {get;set;}

    public  List<String> getJSUrls(){
        return cExternalJS != null ? cExternalJS.split(',') : null;
    }

    public Long offset {get{
			offset = (-1) * UserInfo.getTimeZone().getOffset(Datetime.now())/60000;
			return offset;
    } set;}

    public String locale {get{
        locale = UserInfo.getLocale();
        return locale;
    } set;}

    public String dateFormat {get{
        dateFormat = getUserDateFormat();
        return dateFormat;
    } set;}

    public String dateTimeFormat {get{
        dateTimeFormat = getUserDateTimeFormat();
        return dateTimeFormat;
    } set;}

    public String language {get{
        language = UserInfo.getLanguage();
        return language;
    } set;}

        private static Map<String,String> localeToDateTimeFmtMap;
    // Singleton, remember when first referenced
    //  -------------------------------------------------------
    //  getUserDateFormat: e.g. M/d/yyyy
    //  -------------------------------------------------------
    public static String getUserDateFormat() {
        String userLocale  = UserInfo.getLocale();
        String format;
        getLocaleToDateTimeFmtMap();
        if (
            localeToDateTimeFmtMap.containsKey(userLocale)
            ) {
            format = localeToDateTimeFmtMap.get(userLocale).substringBefore(' ');
        } else {
            if (userLocale.indexOf('_') > 0) {
                String baseLocale = userLocale.substring(0, userLocale.indexOf('_'));
                if (
                    localeToDateTimeFmtMap.containsKey(baseLocale)
                ) {
                    format = localeToDateTimeFmtMap.get(baseLocale).substringBefore(' ');
                }
            } else {
                format = 'yyyy-mm-dd';
            }
        }
        return format;
    }

    //  -------------------------------------------------------
    //  getUserDateTimeFormat: e.g. M/d/yyyy hh.mm.ss
    //  -------------------------------------------------------
    public static String getUserDateTimeFormat() {
        String userLocale  = UserInfo.getLocale();
        String format;
        getLocaleToDateTimeFmtMap();
        if (
            localeToDateTimeFmtMap.containsKey(userLocale)
            ) {
            format = localeToDateTimeFmtMap.get(userLocale);
        } else {
            if (userLocale.indexOf('_') > 0) {
                String baseLocale = userLocale.substring(0, userLocale.indexOf('_'));
                if (
                    localeToDateTimeFmtMap.containsKey(baseLocale)
                ) {
                    format = localeToDateTimeFmtMap.get(baseLocale);
                }
            } else {
                format = 'yyyy-mm-dd hh.mm.ss';
            }
        }
        return format;
    }


    //  -------------------------------------------------------
    //  getLocaleToDateTimeFmtMap                   : Returns a map of user locale | datetime format for that locale (http://www.interactiveties.com/b_locale_datetime.php)
    //  -------------------------------------------------------
    public static Map<String,String> getLocaleToDateTimeFmtMap () {
        if (localeToDateTimeFmtMap == null) {
            localeToDateTimeFmtMap  = new Map<String,String> {
                'af'            =>  'dd/MM/yyyy HH:mm',
                'ar'            =>  'D/‏M/‏yyyy HH:mm',
                'ar_AE'         =>  'dd/MM/yyyy hh:mm',
                'ar_BH'         =>  'dd/MM/yyyy hh:mm',
                'ar_DZ'         =>  'dd/MM/yyyy HH:mm',
                'ar_JO'         =>  'dd/MM/yyyy hh:mm',
                'ar_KW'         =>  'dd/MM/yyyy hh:mm',
                'ar_KW'         =>  'dd/MM/yyyy HH:mm',
                'ar_LB'         =>  'dd/MM/yyyy hh:mm',
                'ar_LY'         =>  'D/‏M/‏yyyy HH:mm',
                'ar_MA'         =>  'dd/MM/yyyy HH:mm',
                'ar_SA'         =>  'dd/MM/yyyy hh:mm',
                'ar_SA'         =>  'dd/MM/yyyy HH:mm',
                'ar_TN'         =>  'dd/MM/yyyy HH:mm',
                'az'            =>  'dd.MM.yyyy HH:mm',
                'be'            =>  'dd.MM.yyyy HH:mm',
                'bg'            =>  'D.MM.yyyy H:mm',
                'bg_BG'         =>  'yyyy-M-d H:mm',
                'bm'            =>  'dd/MM/yyyy HH:mm',
                'bn'            =>  'dd/MM/yyyy h:mm',
                'bo'            =>  'dd/MM/yyyy h:mm',
                'br'            =>  'dd/MM/yyyy h:mm',
                'bs'            =>  'dd.MM.yyyy H:mm',
                'ca'            =>  'dd/MM/yyyy HH:mm',
                'ca'            =>  'dd/MM/yyyy H:mm',
                'ca_ES'         =>  'dd/MM/yyyy HH:mm',
                'ca_ES_EURO'    =>  'dd/MM/yyyy HH:mm',
                'cs'            =>  'd.M.yyyy H:mm',
                'cs'            =>  'dd.MM.yyyy H:mm',
                'cs_CZ'         =>  'd.M.yyyy H:mm',
                'cv'            =>  'dd-MM-yyyy HH:mm',
                'cy'            =>  'dd/MM/yyyy HH:mm',
                'da'            =>  'dd-MM-yyyy HH:mm',
                'da'            =>  'dd.MM.yyyy HH:mm',
                'da_DK'         =>  'dd-MM-yyyy HH:mm',
                'de'            =>  'dd.MM.yyyy HH:mm',
                'de'            =>  'dd.MM.yyyy HH:mm',
                'de_AT'         =>  'dd.MM.yyyy HH:mm',
                'de_AT'         =>  'dd.MM.yyyy HH:mm',
                'de_AT_EURO'    =>  'dd.MM.yyyy HH:mm',
                'de_CH'         =>  'dd.MM.yyyy HH:mm',
                'de_CH'         =>  'dd.MM.yyyy HH:mm',
                'de_DE'         =>  'dd.MM.yyyy HH:mm',
                'de_DE_EURO'    =>  'dd.MM.yyyy HH:mm',
                'de_LU'         =>  'dd.MM.yyyy HH:mm',
                'de_LU_EURO'    =>  'dd.MM.yyyy HH:mm',
                'dv'            =>  'D/M/yyyy HH:mm',
                'el'            =>  'dd/MM/yyyy h:mm',
                'el_GR'         =>  'd/M/yyyy h:mm',
                'en_AU'         =>  'd/MM/yyyy HH:mm',
                'en_AU'         =>  'dd/MM/yyyy h:mm',
                'en_B'          =>  'M/d/yyyy h:mm',
                'en_BM'         =>  'M/d/yyyy h:mm',
                'en_CA'         =>  'dd/MM/yyyy h:mm',
                'en_CA'         =>  'yyyy-MM-dd h:mm',
                'en_GB'         =>  'dd/MM/yyyy HH:mm',
                'en_GB'         =>  'dd/MM/yyyy HH:mm',
                'en_GH'         =>  'M/d/yyyy h:mm',
                'en_ID'         =>  'M/d/yyyy h:mm',
                'en_IE'         =>  'dd/MM/yyyy HH:mm',
                'en_IE'         =>  'dd-MM-yyyy HH:mm',
                'en_IE_EURO'    =>  'dd/MM/yyyy HH:mm',
                'en_NZ'         =>  'd/MM/yyyy HH:mm',
                'en_NZ'         =>  'dd/MM/yyyy h:mm',
                'en_SG'         =>  'M/d/yyyy h:mm',
                'en_US'         =>  'M/d/yyyy h:mm',
                'en_ZA'         =>  'yyyy/MM/dd hh:mm',
                'eo'            =>  'yyyy-MM-dd HH:mm',
                'es'            =>  'd/MM/yyyy H:mm',
                'es'            =>  'dd/MM/yyyy H:mm',
                'es_AR'         =>  'dd/MM/yyyy HH:mm',
                'es_BO'         =>  'dd-MM-yyyy hh:mm',
                'es_CL'         =>  'dd-MM-yyyy hh:mm',
                'es_CO'         =>  'd/MM/yyyy hh:mm',
                'es_CR'         =>  'dd/MM/yyyy hh:mm',
                'es_DO'         =>  'dd/MM/yyyy h:mm',
                'es_EC'         =>  'dd/MM/yyyy hh:mm',
                'es_ES'         =>  'd/MM/yyyy H:mm',
                'es_ES_EURO'    =>  'd/MM/yyyy H:mm',
                'es_GT'         =>  'd/MM/yyyy hh:mm',
                'es_HN'         =>  'MM-dd-yyyy hh:mm',
                'es_MX'         =>  'd/MM/yyyy hh:mm',
                'es_PE'         =>  'dd/MM/yyyy hh:mm',
                'es_PR'         =>  'MM-dd-yyyy hh:mm',
                'es_PY'         =>  'dd/MM/yyyy hh:mm',
                'es_SV'         =>  'MM-dd-yyyy hh:mm',
                'es_US'         =>  'MM/dd/yyyy h:mm',
                'es_UY'         =>  'dd/MM/yyyy hh:mm',
                'es_VE'         =>  'dd/MM/yyyy hh:mm',
                'et'            =>  'dd.MM.yyyy H:mm',
                'et_EE'         =>  'd.MM.yyyy H:mm',
                'eu'            =>  'yyyy-MM-dd HH:mm',
                'fa'            =>  'dd/MM/yyyy HH:mm',
                'fi'            =>  'd.M.yyyy H:mm',
                'fi'            =>  'dd.MM.yyyy HH.mm',
                'fi_FI'         =>  'd.M.yyyy H:mm',
                'fi_FI_EURO'    =>  'd.M.yyyy H:mm',
                'fo'            =>  'dd/MM/yyyy HH:mm',
                'fr'            =>  'dd/MM/yyyy HH:mm',
                'fr'            =>  'dd/MM/yyyy HH:mm',
                'fr_BE'         =>  'd/MM/yyyy H:mm',
                'fr_CA'         =>  'yyyy-MM-dd HH:mm',
                'fr_CA'         =>  'yyyy-MM-dd HH:mm',
                'fr_CH'         =>  'dd.MM.yyyy HH:mm',
                'fr_CH'         =>  'dd.MM.yyyy HH:mm',
                'fr_FR'         =>  'dd/MM/yyyy HH:mm',
                'fr_FR_EURO'    =>  'dd/MM/yyyy HH:mm',
                'fr_LU'         =>  'dd/MM/yyyy HH:mm',
                'fr_MC'         =>  'dd/MM/yyyy HH:mm',
                'fy'            =>  'dd-MM-yyyy HH:mm',
                'gd'            =>  'dd/MM/yyyy HH:mm',
                'gl'            =>  'dd/MM/yyyy H:mm',
                'gom_LATN'      =>  'dd-MM-yyyy h:mm',
                'gu'            =>  'dd/MM/yyyy h:mm',
                'he'            =>  'dd/MM/yyyy HH:mm',
                'hi'            =>  'dd/MM/yyyy h:mm',
                'hr'            =>  'dd.MM.yyyy H:mm',
                'hr_HR'         =>  'yyyy.MM.dd HH:mm',
                'hu'            =>  'yyyy.MM.dd. H:mm',
                'hu'            =>  'yyyy.MM.dd. H:mm',
                'hy_AM'         =>  'M/d/yyyy h:mm',
                'hy_AM'         =>  'dd.MM.yyyy HH:mm',
                'id'            =>  'dd/MM/yyyy HH.mm',
                'is'            =>  'dd.MM.yyyy H:mm',
                'is_IS'         =>  'd.M.yyyy HH:mm',
                'it'            =>  'dd/MM/yyyy H.mm',
                'it'            =>  'dd/MM/yyyy HH:mm',
                'it_CH'         =>  'dd.MM.yyyy HH:mm',
                'it_IT'         =>  'dd/MM/yyyy H.mm',
                'iw'            =>  'HH:mm dd/MM/yyyy',
                'iw_IL'         =>  'HH:mm dd/MM/yyyy',
                'ja'            =>  'yyyy/MM/dd H:mm',
                'ja'            =>  'yyyy/MM/dd HH:mm',
                'ja_JP'         =>  'yyyy/MM/dd H:mm',
                'jv'            =>  'dd/MM/yyyy HH.mm',
                'ka'            =>  'dd/MM/yyyy h:mm',
                'kk'            =>  'dd.MM.yyyy HH:mm',
                'kk_KZ'         =>  'M/d/yyyy h:mm',
                'km'            =>  'dd/MM/yyyy HH:mm',
                'km_KH'         =>  'M/d/yyyy h:mm',
                'kn'            =>  'dd/MM/yyyy h:mm',
                'ko'            =>  'yyyy. M. d h:mm',
                'ko'            =>  'yyyy.MM.dd h:mm',
                'ko_KR'         =>  'yyyy. M. d h:mm',
                'ky'            =>  'dd.MM.yyyy HH:mm',
                'lb'            =>  'dd.MM.yyyy H:mm',
                'lo'            =>  'dd/MM/yyyy HH:mm',
                'lt'            =>  'yyyy-MM-dd HH:mm',
                'lt_LT'         =>  'yyyy.M.d HH.mm',
                'lv'            =>  'dd.MM.yyyy. HH:mm',
                'lv_LV'         =>  'yyyy.d.M HH:mm',
                'me'            =>  'dd.MM.yyyy H:mm',
                'mi'            =>  'dd/MM/yyyy HH:mm',
                'mk'            =>  'D.MM.yyyy H:mm',
                'ml'            =>  'dd/MM/yyyy h:mm',
                'mr'            =>  'dd/MM/yyyy h:mm',
                'ms'            =>  'dd/MM/yyyy HH.mm',
                'ms_MY'         =>  'dd/MM/yyyy h:mm',
                'ms_MY'         =>  'dd/MM/yyyy HH.mm',
                'mt'            =>  'dd/MM/yyyy HH:mm',
                'my'            =>  'dd/MM/yyyy HH:mm',
                'nb'            =>  'dd.MM.yyyy HH:mm',
                'ne'            =>  'dd/MM/yyyy h:mm',
                'nl'            =>  'd-M-yyyy H:mm',
                'nl'            =>  'dd-MM-yyyy HH:mm',
                'nl_BE'         =>  'd/MM/yyyy H:mm',
                'nl_BE'         =>  'dd/MM/yyyy HH:mm',
                'nl_NL'         =>  'd-M-yyyy H:mm',
                'nl_SR'         =>  'd-M-yyyy H:mm',
                'nn'            =>  'dd.MM.yyyy HH:mm',
                'no'            =>  'dd.MM.yyyy HH:mm',
                'no_NO'         =>  'dd.MM.yyyy HH:mm',
                'pa_IN'         =>  'dd/MM/yyyy h:mm',
                'pl'            =>  'yyyy-MM-dd HH:mm',
                'pl'            =>  'dd.MM.yyyy HH:mm',
                'pt'            =>  'dd-MM-yyyy H:mm',
                'pt'            =>  'dd/MM/yyyy HH:mm',
                'pt_AO'         =>  'dd-MM-yyyy H:mm',
                'pt_BR'         =>  'dd/MM/yyyy HH:mm',
                'pt_BR'         =>  'dd/MM/yyyy HH:mm',
                'pt_PT'         =>  'dd-MM-yyyy H:mm',
                'ro'            =>  'dd.MM.yyyy H:mm',
                'ro_RO'         =>  'dd.MM.yyyy HH:mm',
                'ru'            =>  'dd.MM.yyyy H:mm',
                'ru'            =>  'dd.MM.yyyy H:mm',
                'sd'            =>  'dd/MM/yyyy HH:mm',
                'se'            =>  'dd.MM.yyyy HH:mm',
                'si'            =>  'yyyy/MM/dd h:mm',
                'sk'            =>  'dd.MM.yyyy H:mm',
                'sk_SK'         =>  'd.M.yyyy H:mm',
                'sl'            =>  'dd.MM.yyyy H:mm',
                'sl_SI'         =>  'd.M.y H:mm',
                'sq'            =>  'dd/MM/yyyy HH:mm',
                'sr'            =>  'dd.MM.yyyy H:mm',
                'sr_CYRL'       =>  'dd.MM.yyyy H:mm',
                'ss'            =>  'dd/MM/yyyy h:mm',
                'sv'            =>  'yyyy-MM-dd HH:mm',
                'sv'            =>  'yyyy-MM-dd HH:mm',
                'sv_SE'         =>  'yyyy-MM-dd HH:mm',
                'sw'            =>  'dd.MM.yyyy HH:mm',
                'ta'            =>  'dd/MM/yyyy HH:mm',
                'te'            =>  'dd/MM/yyyy h:mm',
                'tet'           =>  'dd/MM/yyyy HH:mm',
                'th'            =>  'M/d/yyyy h:mm',
                'th'            =>  'dd/MM/yyyy H:mm',
                'th_TH'         =>  'd/M/yyyy, H:mm',
                'tl_PH'         =>  'MM/D/yyyy HH:mm',
                'tlh'           =>  'dd.MM.yyyy HH:mm',
                'tr'            =>  'dd.MM.yyyy HH:mm',
                'tr'            =>  'dd.MM.yyyy HH:mm',
                'tzl'           =>  'dd.MM.yyyy HH.mm',
                'tzm'           =>  'dd/MM/yyyy HH:mm',
                'tzm_LATN'      =>  'dd/MM/yyyy HH:mm',
                'uk'            =>  'dd/MM/yyyy HH:mm',
                'ur'            =>  'dd/MM/yyyy HH:mm',
                'ur_PK'         =>  'M/d/yyyy h:mm',
                'uz'            =>  'dd/MM/yyyy HH:mm',
                'uz_LATN'       =>  'dd/MM/yyyy HH:mm',
                'vi'            =>  'dd/MM/yyyy HH:mm',
                'vi_VN'         =>  'HH:mm dd/MM/yyyy',
                'x_PSEUDO'      =>  'dd/MM/yyyy HH:mm',
                'yo'            =>  'dd/MM/yyyy h:mm',
                'zh'            =>  'yyyy-M-d h:mm',
                'zh_CN'         =>  'yyyy-M-d h:mm',
                'zh_CN'         =>  'yyyy/MM/dd HH:mm',
                'zh_HK'         =>  'yyyy-M-d h:mm',
                'zh_HK'         =>  'yyyy/MM/dd HH:mm',
                'zh_TW'         =>  'yyyy/M/d h:mm',
                'zh_TW'         =>  'yyyy/MM/dd HH:mm'
            };
        }
        return localeToDateTimeFmtMap;
    }

}