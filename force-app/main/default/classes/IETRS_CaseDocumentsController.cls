/**
 * Controller class for the IETRS_CaseDocuments VF component.
 * @author CGI
 */
public with sharing class IETRS_CaseDocumentsController {
    /**
     * The relevant list of case documents based on the provided user id,
     *  start date, duration and the user's case subscriptions.
     */
    public List<IETRS_Public_File_Correspondence__c> caseDocuments {
        get {
            if (this.caseDocuments == null) {
                List<IETRS_Public_File_Correspondence__c> result = [
                    SELECT
                        Id,
                        IETRS_Original_File_Name__c,
                        IETRS_Document_Type__c,
                        IETRS_Case__r.CaseNumber,
                        IETRS_Case__r.IETRS_Primary_Account_Assignment__r.Name,
                        CreatedDate
                    FROM IETRS_Public_File_Correspondence__c
                    WHERE
                        IETRS_Case__c IN :this.subscribedCaseIds
                        AND CreatedDate >= :this.startDate
                        AND CreatedDate < :this.endDate
                    ORDER BY IETRS_Case__c
                ];
                this.caseDocuments = result;
            }
            return this.caseDocuments;
        }
        private set;
    }

    /**
     * List of case ids the user is subcribed to.
     */
    Set<Id> subscribedCaseIds {
        get {
            if (this.subscribedCaseIds == null) {
                Set<Id> result = new Set<Id>();
                for (IETRS_Case_Subscription__c cs : [
                    SELECT IETRS_Case__c
                    FROM IETRS_Case_Subscription__c
                    WHERE OwnerId = :this.cntrlUserId
                ]) {
                    result.add(cs.IETRS_Case__c);
                }
                this.subscribedCaseIds = result;
            }
            return this.subscribedCaseIds;
        }
        set;
    }

    /**
     * Start date used in the filter to find case documents.
     */
    public DateTime startDate {
        get {
            Date dt = System.today().addDays(-1);
            if (this.cntrlDocumentDate != null) {
                dt = Date.valueOf(this.cntrlDocumentDate);
            }
            return DateTime.newInstance(
                dt.year(),
                dt.month(),
                dt.day(),
                0,
                0,
                0
            );
        }
    }

    /**
     * Calculated end date used in the filter to find case documents.
     */
    public DateTime endDate {
        get {
            Integer days = this.cntrlDuration == null
                ? 1
                : Math.max(1, this.cntrlDuration);
            return this.startDate.addDays(days);
        }
    }

    /**
     * Id of the user who is registered to be notified of new case documents.
     */
    public Id cntrlUserId {
        get;
        set {
            if (value == null) {
                value = UserInfo.getUserId();
            }
            this.cntrlUserId = Id.valueOf(value);
        }
    }

    /**
     * Date used to find new documents. Formatted as yyyy-MM-dd.
     */
    public String cntrlDocumentDate { get; set; }

    /**
     * Duration in days from the start date.
     */
    public Integer cntrlDuration { get; set; }

    /**
     * Site url for the RRC_Portal experience site if the recipient
     *  is an external user; internal org base url if internal.
     */
    public String siteUrl {
        get {
            if (this.siteUrl == null) {
                String result =
                    URL.getSalesforceBaseUrl().toExternalForm() + '/';
                if (this.isExternalUser) {
                    Id siteId = [
                        SELECT Id
                        FROM Site
                        WHERE Name = 'RRC_Portal_C'
                        LIMIT 1
                    ]
                    ?.Id;
                    if (siteId != null) {
                        result =
                            [
                                SELECT SecureUrl
                                FROM SiteDetail
                                WHERE DurableId = :siteId
                                LIMIT 1
                            ]
                            ?.SecureUrl + '/detail/';
                    }
                }
                this.siteUrl = result;
            }
            return this.siteUrl;
        }
        private set;
    }

    /**
     * Indicates if the recipient user is an external user.
     */
    Boolean isExternalUser {
        get {
            if (this.isExternalUser == null) {
                Boolean result = [
                    SELECT IsPortalEnabled
                    FROM User
                    WHERE Id = :cntrlUserId
                    LIMIT 1
                ]
                ?.IsPortalEnabled;
                this.isExternalUser = result;
            }
            return this.isExternalUser;
        }
        set;
    }
}