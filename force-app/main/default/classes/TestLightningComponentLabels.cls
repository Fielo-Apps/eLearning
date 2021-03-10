@isTest
public class TestLightningComponentLabels {
    @isTest
    public static void testLabels() {
        LightningComponentLabels labels = new LightningComponentLabels();

        System.assert(!labels.ELR_LABELS.isEmpty(), 'FieloELR HAS NO LABELS!');
    }
}
