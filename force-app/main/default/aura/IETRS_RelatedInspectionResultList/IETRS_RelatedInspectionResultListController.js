({
    /**
     * Handle the component initialization.
     *  If no recordId is available, gets the record id from the page reference.
     * @param  {Object} cmp - The component in scope.
     */
    handleInit: function(cmp) {
        var recordId = cmp.get('v.recordId');
        if (!recordId) {
            var pageRef = cmp.get('v.pageReference');
            var recordId = pageRef.state.c__recordId;
            cmp.set('v.recordId', recordId);
        }
    },

    /**
     * Handle the unsaved changes event from the inspection result lwc.
     *  Indicates that there are unsaved changes in the component.
     * @param  {Object} cmp - The component in scope.
     */
    handleUnsavedChange: function(cmp) {
        var unsaved = cmp.find('unsaved');
        unsaved.setUnsavedChanges(true, { label: 'Inspection Checklist' });
    },

    /**
     * Handle the save event from the inspection result lwc.
     *  Indicates that there are no unsaved changes in the component.
     * @param  {Object} cmp - The component in scope.
     */
    handleClearUnsavedChange: function(cmp) {
        var unsaved = cmp.find('unsaved');
        unsaved.setUnsavedChanges(false);
    },

    /**
     * Handle the save event from unsaved changes component.
     *  Saves the unsaved changes before leaving the component.
     * @param  {Object} cmp - The component in scope.
     */
    handleSaveChanges: function(cmp) {
        var inspectionResults = cmp.find('inspectionResults');
        inspectionResults.saveRecords();
    },

    /**
     * Handle the discard event from unsaved changes component.
     *  Close the current tab and lose unsaved changes.
     * @param  {Object} cmp - The component in scope.
     * @param  {Event} evt - The discard changes event.
     * @param  {Object} h - The helper resource for the component.
     */
    handleDiscardChanges: function(cmp, evt, h) {
        var unsaved = cmp.find('unsaved');
        unsaved.setUnsavedChanges(false);
        h.closeTab(cmp);
    },

    /**
     * Handle the closetab event from the inspection results component.
     * @param  {Object} cmp - The component in scope.
     * @param  {Event} evt - The discard changes event.
     * @param  {Object} h - The helper resource for the component.
     */
    handleCloseTab: function(cmp, evt, h) {
        h.closeTab(cmp);
    }
});