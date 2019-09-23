@isTest
public class TestAnswerOptionsController {
	
	@isTest
    static void testSectFormFd() {
	
	AnswerOptionsController answerOptContrl = new AnswerOptionsController();

	answerOptContrl.csObjectName = 'none';
	answerOptContrl.cFieldset = '{"Name":"Information","Rows":[[{"Name":"FieloELR__Order__c", "Type":"input"}],[{"Name":"FieloELR__AnswerOptionText__c", "Type":"input"}],[{"Name":"FieloELR__IsCorrect__c", "Type":"checkbox"}]]}';
	answerOptContrl.cbuttons = 'none';

    AnswerOptionsController.Section section = new AnswerOptionsController.Section();
    section.Name =  'none';
    section.CssClass = 'none';
    

    System.assertEquals('none', section.Name);
    System.assertEquals('none', section.CssClass);



    AnswerOptionsController.FormField formfield = new AnswerOptionsController.FormField();
    formfield.Type = 'none';
    formfield.MetaField = 'none';
    formfield.onchange = 'none';
    formfield.Label = 'none';
    formfield.Value = 'none';
    formfield.Name = 'none';
    formfield.ClassName = 'none';
    formfield.WhereCondition = 'none';
    
    List<AnswerOptionsController.FormField> innerList = new List<AnswerOptionsController.FormField>{formfield};
   section.Rows = new List<List<AnswerOptionsController.FormField>>{innerList};

    System.assertEquals('none', formfield.Type);
    System.assertEquals('none', formfield.MetaField);
    System.assertEquals('none', formfield.onchange);
    System.assertEquals('none', formfield.Value);
    System.assertEquals(null, formfield.Required);
    System.assertEquals('', formfield.getRequiredValue());
    
    formfield.Required = true;
    System.assertEquals(true, formfield.Required);
    System.assertEquals('true', formfield.getRequiredValue());

    List<AnswerOptionsController.Section> innerSection = new List<AnswerOptionsController.Section>{section};
     //answerOptContrl.sections result 1 = List<AnswerOptionsController.Section>;
    
    answerOptContrl.fields = null;
    String result =  answerOptContrl.fields;


    }
	
}
