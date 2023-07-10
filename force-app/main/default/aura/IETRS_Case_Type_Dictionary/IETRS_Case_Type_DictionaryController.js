({
    onRender: function(cmp) {
        window.open($A.get("$Label.c.IETRS_Case_Type_Dictionary"));
        $A.get("e.force:closeQuickAction").fire();
    }
})