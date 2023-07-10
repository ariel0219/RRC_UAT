({
    /**
     * Close the current tab.
     * @param  {Object} cmp - The component in scope.
     */
    closeTab: function(cmp) {
        var workspaceAPI = cmp.find('workspace');
        workspaceAPI
            .getFocusedTabInfo()
            .then(function(response) {
                var focusedTabId = response.tabId;
                workspaceAPI.closeTab({ tabId: focusedTabId });
            })
            .catch(function(error) {
                console.log(error);
            });
    }
});