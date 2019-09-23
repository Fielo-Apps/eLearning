public with sharing class BackendFooterController {
	public String cExternalJS {get;set;}

    public  List<String> getJSUrls(){
        return cExternalJS != null ? cExternalJS.split(',') : null;
    }

    public Long offset {get{
    	DateTime now = DateTime.now();
			offset = DateTime.newInstance(now.date(), now.time()).getTime() - DateTime.newInstance(now.dateGmt(), now.timeGmt()).getTime();
			offset = (-1) * offset / (60 * 1000);
			return offset;
    } set;}
		
}