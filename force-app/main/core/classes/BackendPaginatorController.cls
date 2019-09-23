public with sharing class BackendPaginatorController {
  public String filter {get;set;}
  public String cFilter {get{
    if(cFilter == null && filter != null){
      cFilter = filter.replace('\'','"');
    }
      return cFilter;
    }set;}
}