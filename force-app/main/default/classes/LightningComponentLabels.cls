public with sharing class LightningComponentLabels {
    public List<String> ELR_LABELS;

    public LightningComponentLabels() {
        // necessary to add labels to the package

        // There are 606 labels in FieloELR
        ELR_LABELS = new List<String>{
            Label.Accomplishment,
            Label.AccomplishmentFormula,
            Label.Actions,
            Label.ActionsDeleteValidation,
            Label.ActiveCourseCannotBeEdited,
            Label.ActiveCourseMustHaveActiveModules,
            Label.ActiveModuleCannotBeEdited,
            Label.ActiveModuleQuestionNotEditable,
            Label.ActiveOption,
            Label.Add,
            Label.AddCriterion,
            Label.AddMembers,
            Label.AddReward,
            Label.AdjustmentTransaction,
            Label.Advanced,
            Label.Agreement,
            Label.AgreementUsed,
            Label.AgreementWarningUse,
            Label.All,
            Label.AlreadyInDescribeCache,
            Label.And,
            Label.AnswerCannotBeEdited,
            Label.AnswerOptionTextRequired,
            Label.AnswerTheQuestions,
            Label.Any,
            Label.Approved,
            Label.Areyousure,
            Label.AssignedBadge,
            Label.AssignedPoints,
            Label.AssignedReward,
            Label.AtLeastLookupTransactionOrTracker,
            Label.AtLeastOneChallengeReward,
            Label.AtLeastOneMission,
            Label.AtLeastOneRule,
            Label.AuditLogs,
            Label.AuditPermissions,
            Label.Available,
            Label.AvailableCourses,
            Label.AvailableRewards,
            Label.Back,
            Label.BadgeSpecifiedByFieldHelp,
            Label.Basic,
            Label.BatchScheduleLevelAssignmentHelp,
            Label.BatchScheduleLevelAssignmentName,
            Label.BatchSchedulePartialPointsExpirationHelp,
            Label.BatchSchedulePartialPointsExpirationName,
            Label.BatchSchedulePointsExpirationHelp,
            Label.BatchSchedulePointsExpirationName,
            Label.BatchScheduleRedemptionItemExpirationHelp,
            Label.BatchScheduleRedemptionItemExpirationName,
            Label.BatchScheduleTransactionOfflineHelp,
            Label.BatchScheduleTransactionOfflineName,
            Label.BatchesProcessed,
            Label.BrowseExisting,
            Label.CRMAccountsRelated,
            Label.CRMContactIndividualAccountError,
            Label.Cancel,
            Label.CannotAccessRecords,
            Label.CannotChangeAnsweredModules,
            Label.CannotDeleteActiveModuleInActiveCourse,
            Label.CannotDeleteRecords,
            Label.CannotInsertRecords,
            Label.CannotInsertUpdateRecords,
            Label.Categories,
            Label.ChRewardDifferentLogicalExpression,
            Label.ChRewardInvalidFrom,
            Label.ChRewardInvalidFrom2,
            Label.ChRewardInvalidFrom3,
            Label.ChRewardInvalidLogicalExpression,
            Label.ChRewardMissingData,
            Label.ChRewardMissingFrom,
            Label.ChRewardMissingPointType,
            Label.ChRewardMissingTo,
            Label.ChallengeAlreadyProcessed,
            Label.ChallengeCannotBeActivated,
            Label.ChallengeCannotDelete,
            Label.ChallengeStatus,
            Label.ChallengeStatusDescription,
            Label.Change,
            Label.ChangeProgram,
            Label.ChooseDate,
            Label.ChooseQuestionType,
            Label.ChooseUser,
            Label.Clone,
            Label.Close,
            Label.Codes,
            Label.CollapseAll,
            Label.Comment,
            Label.CompleteAllQuestions,
            Label.CompleteRequiredFields,
            Label.CompletedDate,
            Label.CompletedOn,
            Label.CompletedOption,
            Label.ConfirmBlockUnblock,
            Label.ConfirmSetManager,
            Label.Continue,
            Label.ContributorManagerRequired,
            Label.CorrectAnswer,
            Label.CorrectQuestions,
            Label.CourseActivated,
            Label.CourseCompleted,
            Label.CourseCreated,
            Label.CourseFutureDatesNotAllowed,
            Label.CourseInactivated,
            Label.CourseIsRequired,
            Label.CourseRequiredField,
            Label.CourseStatusMustBeActive,
            Label.Courses,
            Label.Create,
            Label.CreateFieloAccounts,
            Label.CreatedDate,
            Label.Criteria,
            Label.CurrencyRangeSuffix,
            Label.Custom,
            Label.DataRemovedSuccessfully,
            Label.DataSavedSuccessfully,
            Label.Date,
            Label.DateRangeSuffix,
            Label.DatetimeRangeSuffix,
            Label.DefaultPromotion,
            Label.Delete,
            Label.DeleteOrganizationAccountWithContributors,
            Label.DependencyHelpText,
            Label.Description,
            Label.Detail,
            Label.Displaying,
            Label.DoubleRangeSuffix,
            Label.DuplicateRecordOn,
            Label.DuplicateRecords,
            Label.Edit,
            Label.EditAccomplishment,
            Label.EditReward,
            Label.Editor,
            Label.EndDateRequired,
            Label.Error,
            Label.ErrorActivePerformanceChallenge,
            Label.ErrorAddOneReward,
            Label.ErrorAdminFields,
            Label.ErrorAvailableVoucherCodes,
            Label.ErrorChallengeSegment,
            Label.ErrorChooseAssignedPoints,
            Label.ErrorChooseBadge,
            Label.ErrorChooseInstantReward,
            Label.ErrorDateInvalid,
            Label.ErrorDeleteDefaultProgram,
            Label.ErrorDeleteFieloAccount,
            Label.ErrorDeleteItemsQuantity,
            Label.ErrorDescription,
            Label.ErrorEditAgreement,
            Label.ErrorFieloAccountBlocked,
            Label.ErrorFileIsEmpty,
            Label.ErrorImageCeroDimensions,
            Label.ErrorImageType,
            Label.ErrorInactiveMember,
            Label.ErrorInsufficientPoints,
            Label.ErrorInsufficientStock,
            Label.ErrorManageStock,
            Label.ErrorMemberLookup,
            Label.ErrorMetasegmentDeletion,
            Label.ErrorMissionWIthoutObjectiveChallengeObjetiveTime,
            Label.ErrorOneMissionWithoutObjectivePerformance,
            Label.ErrorOrganizationAccountAction,
            Label.ErrorPointDelete,
            Label.ErrorPointsCreate,
            Label.ErrorQueryInvalidFieldNull,
            Label.ErrorRankingSelected,
            Label.ErrorRedemptionCreateBackEndQuantity,
            Label.ErrorRedemptionDelete,
            Label.ErrorRedemptionEngine,
            Label.ErrorRedemptionItemsDeliver,
            Label.ErrorRedemptionItemsRequired,
            Label.ErrorRequiredCriterionField,
            Label.ErrorRequiredRuleTriggers,
            Label.ErrorReviewErrorsForm,
            Label.ErrorRewardsCreateItems,
            Label.ErrorRewardsDelete,
            Label.ErrorSelectCriterionValue,
            Label.ErrorShoppingcartQuantityInput,
            Label.ErrorTheMemberDoesNotExist,
            Label.ErrorTransactionAdjustmentReversion,
            Label.ErrorTransactionNotEditDelete,
            Label.ErrorTransferMember,
            Label.ErrorUploadFileTryAgain,
            Label.ExistingDocument,
            Label.ExpandAll,
            Label.ExportLevels,
            Label.ExportSegments,
            Label.ExternalURL,
            Label.ExternalURLPhotoUpload,
            Label.Failures,
            Label.False,
            Label.Feedback,
            Label.Field,
            Label.FieldCannotBeEdited,
            Label.FieloIcons,
            Label.Fielo_ChangeStatus,
            Label.File,
            Label.Filter,
            Label.First,
            Label.FontAwesomeIcons,
            Label.ForgotPassword,
            Label.From,
            Label.GenerateOrder,
            Label.Go,
            Label.GotoList,
            Label.GotoProcesses,
            Label.GrantAdminPermissions,
            Label.HaventSelectMember,
            Label.HaventSelectedMember,
            Label.Help,
            Label.HelpChRewardContinue,
            Label.HideContent,
            Label.ImageURL,
            Label.Import,
            Label.ImportLevels,
            Label.ImportSegments,
            Label.ImportSuccess,
            Label.ImportSuccessful,
            Label.InfoCategoryChangePhoto,
            Label.InfoChangePhoto,
            Label.InfoDragDropTable,
            Label.InfoEmptyTable,
            Label.InfoLevelChangePhoto,
            Label.InfoLoadItemsByFile,
            Label.InfoManageRewardTablePositionRanking,
            Label.InfoManageRewardTableStandar,
            Label.InfoManageRewardTableStandard,
            Label.InfoManageRewardTableValueRanking,
            Label.InfoMemberCreateFromAccount,
            Label.InfoModifyReward,
            Label.InfoNoActionForRuleTrigger,
            Label.InfoNoMembersAdd,
            Label.InfoRedemptionApproval,
            Label.InfoRedemptionCreateBackEnd,
            Label.InfoRewarItemLoadInserted,
            Label.InfoRewarItemLoadInsertedFailed,
            Label.InfoRewardChangePhoto,
            Label.InfoRewardGenerateItemsWhenStockUnlimited,
            Label.InfoTagChangePhoto,
            Label.Information,
            Label.InstantBadge,
            Label.InstantBadgeFixedValueAndSpecifiedByFieldHelp,
            Label.InstantReward,
            Label.InstantRewardFixedValueAndSpecifiedByFieldHelp,
            Label.InvalidArgument,
            Label.InvalidConditionField,
            Label.InvalidDateField,
            Label.InvalidLogicalExpression,
            Label.InvalidLookupFromTracker,
            Label.InvalidLookupFromTransaction,
            Label.InvalidMember,
            Label.InvalidObject,
            Label.InvalidSObjectTypeNull,
            Label.InvalidValue,
            Label.Items,
            Label.ItemsRequired,
            Label.JSONArrayRequired,
            Label.Join,
            Label.JoinCourse,
            Label.Last,
            Label.LevelErrorOrderWithoutCriteria,
            Label.LevelErrorUniqueLevelWithoutCriteria,
            Label.LevelImportErrorType,
            Label.LevelProcessingStatus,
            Label.Levels,
            Label.ListAvailableMembers,
            Label.Loading,
            Label.LookupFromTrackerNotEmpty,
            Label.LookupFromTransactionNotEmpty,
            Label.LookupsMandatoryRuleTrigger,
            Label.Manage,
            Label.ManageRewards,
            Label.MarkAsUsed,
            Label.MatchCriteria,
            Label.MatchingTextRequired,
            Label.MaximumAttempts,
            Label.Member,
            Label.MemberApprovalSubmit,
            Label.MemberDoesntApplyToCourseSegment,
            Label.MemberExist,
            Label.MemberExistingUser,
            Label.MemberIdRequired,
            Label.MemberInvalid,
            Label.MemberRequired,
            Label.MemberRequiredField,
            Label.MemberShouldBelongToCourseProgram,
            Label.MembersInvalid,
            Label.MessageSent,
            Label.MissionCriterionDifferentFieldType,
            Label.MissionCriterionInvalidFieldName,
            Label.MissionCriterionInvalidOperator,
            Label.MissionCriterionInvalidValues,
            Label.MissionCriterionMissingDateValue,
            Label.MissionCriterionMissingFieldName,
            Label.MissionCriterionMissingFieldType,
            Label.MissionCriterionMissingNumberValue,
            Label.MissionCriterionMissingOperator,
            Label.MissionCriterionMissingValues,
            Label.MissionCriterionMissingValues2,
            Label.MissionInvalidFieldToAggregate,
            Label.MissionInvalidLogicalExpression,
            Label.MissionInvalidObjectiveField,
            Label.MissionWithoutFieldToAggregate,
            Label.MissionWithoutObjectiveField,
            Label.MissionWithoutObjectiveType,
            Label.MissionWithoutObjectiveValue,
            Label.Mode,
            Label.Module,
            Label.ModuleActivated,
            Label.ModuleContentText,
            Label.ModuleInactivated,
            Label.ModuleRequiredField,
            Label.ModuleSubmitted,
            Label.Modules,
            Label.More,
            Label.MustChooseALogicalExpresion,
            Label.MustCompleteOneOfTheActions,
            Label.MyCourses,
            Label.Name,
            Label.NetPoints,
            Label.New,
            Label.NewRecordsCannotRegisteredDeletion,
            Label.NewRedemption,
            Label.Next,
            Label.NoContent,
            Label.NoMissions,
            Label.NoRecordsToShow,
            Label.NoResultsFound,
            Label.None,
            Label.NotApproved,
            Label.NotEnabled,
            Label.NotPassed,
            Label.NotProcessed,
            Label.NotRegistered,
            Label.NotSupportedByUnitOfWork,
            Label.OK,
            Label.OR,
            Label.ObjectCannotBeModified,
            Label.Of,
            Label.OnModuleCreationError,
            Label.OnlyNewRecordsRegisteredAsNew,
            Label.OnlyOneMIssionWithoutObjective,
            Label.OnlyWithInactiveActionCanBeDeleted,
            Label.OperationSuccessful,
            Label.Operator,
            Label.Order,
            Label.OrderRecordsNoRecords,
            Label.OrgAccountContributorError,
            Label.OrganizationAccountAlreadyExist,
            Label.OrganizationAccountCRMRequired,
            Label.OrganizationAccountMustHaveAManager,
            Label.OrganizationAccountProgramError,
            Label.OrganizationAccountRelatedRequired,
            Label.OutOfCoursePeriod,
            Label.Page,
            Label.Passed,
            Label.Password,
            Label.PasswordIsRequired,
            Label.PastVouchers,
            Label.PenaltyAndIncorrectWeightSet,
            Label.PercentRangeSuffix,
            Label.Period,
            Label.PersonAccountNotEnabled,
            Label.PhotoProfile,
            Label.PhotoUpload,
            Label.Picklist,
            Label.PleaseCompleteTheNecessaryInfo,
            Label.PleaseSelectAnImageToUpload,
            Label.PleaseSelectAtLeastOneAccount,
            Label.PleaseSelectAtLeastOneContact,
            Label.Points,
            Label.PointsEarned,
            Label.Position,
            Label.PositionStandardValue,
            Label.PredecessorRequired,
            Label.Prerequisites,
            Label.Preview,
            Label.Previous,
            Label.PrivateSegmentAlreadyExists,
            Label.ProcessOffline,
            Label.Processed,
            Label.Profile,
            Label.Program,
            Label.ProgramAdvanceExpirationMode,
            Label.ProgramAdvanceLanguage,
            Label.ProgramDefaultError,
            Label.ProgramRequired,
            Label.ProgramSetDefault,
            Label.ProgramWithoutCurrentAgrrement,
            Label.Progress,
            Label.PromotionStatus,
            Label.PromotionStatusDescription,
            Label.PromotionTimeline,
            Label.Promotions,
            Label.PublicSegmentAlreadyExists,
            Label.Quantity,
            Label.QuantityExcedeed,
            Label.QueryErrorCrossObjectFields,
            Label.QueryErrorInvalidCall,
            Label.QueryErrorInvalidCall2,
            Label.QueryErrorInvalidCall3,
            Label.QueryErrorInvalidField,
            Label.QueryErrorInvalidFieldSet,
            Label.QueryErrorInvalidRelationship,
            Label.Question,
            Label.QuestionAlreadyAnsweredCorrectly,
            Label.QuestionFieldRequired,
            Label.QuestionPoolGreaterThenQuestionNumber,
            Label.QuestionReadOnlyFields,
            Label.QuestionTextRequired,
            Label.QuestionsGreaterThanQuestionPool,
            Label.QuickSave,
            Label.RangeSuffix,
            Label.Recent,
            Label.RecentMembers,
            Label.RecentPromotions,
            Label.RecentlyCreated,
            Label.RecentlyModified,
            Label.RecordCannotBeRegisteredAsDirty,
            Label.RecordDeletedSuccessfully,
            Label.RecordName,
            Label.RecordSubmittedForApproval,
            Label.RecordTypeOfNewRecord,
            Label.RecordWasDeleted,
            Label.Redeem,
            Label.RedeemRewardVoucher,
            Label.Redemption,
            Label.RedemptionItemProgramValidation,
            Label.RedemptionItemRevertError,
            Label.RedemptionItemSelectOne,
            Label.RegisterExistingUser,
            Label.Registered,
            Label.Reload,
            Label.Remove,
            Label.Replace,
            Label.ReportAnIssue,
            Label.RequiredArgument,
            Label.Results,
            Label.RetakeQuiz,
            Label.ReviewFollowingErrors,
            Label.ReviewYourQuestions,
            Label.Revoke,
            Label.RewardCatalog,
            Label.RewardErrorDuplicateValue,
            Label.RewardErrorFileEmpty,
            Label.RewardErrorFileNull,
            Label.RewardErrorFormatFile,
            Label.RewardErrorIntangible,
            Label.RewardErrorNull,
            Label.RewardErrorSizeFile,
            Label.RewardRequired,
            Label.RewardSpecifiedByFieldHelp,
            Label.Rewards,
            Label.Rule,
            Label.RuleCriterionDifferentFieldType,
            Label.RuleCriterionInvalidFieldName,
            Label.RuleCriterionInvalidOperator,
            Label.RuleCriterionInvalidValues,
            Label.RuleCriterionWithoutDateValue,
            Label.RuleCriterionWithoutFieldName,
            Label.RuleCriterionWithoutFieldType,
            Label.RuleCriterionWithoutNumberValue,
            Label.RuleCriterionWithoutOperator,
            Label.RuleCriterionWithoutValues,
            Label.RuleCriterionWithoutValues2,
            Label.RuleInvalidBadgeFieldName,
            Label.RuleInvalidLogicalExpression,
            Label.RuleInvalidRelatedList,
            Label.RuleInvalidRewardFieldName,
            Label.RuleInvalidTransactionFieldName,
            Label.RuleRewardProgramValidation,
            Label.RuleWithoutAction,
            Label.RuleWithoutBadgeFieldName,
            Label.RuleWithoutConversionValue,
            Label.RuleWithoutInstantBadge,
            Label.RuleWithoutInstantReward,
            Label.RuleWithoutPointType,
            Label.RuleWithoutRewardFieldName,
            Label.RuleWithoutTransactionFieldName,
            Label.RuleWithoutType,
            Label.Rules,
            Label.Save,
            Label.SaveAndNew,
            Label.ScheduledOption,
            Label.Search,
            Label.SearchBy,
            Label.SearchObjects,
            Label.SegmentImportErrorType,
            Label.Segments,
            Label.Select,
            Label.SelectAFile,
            Label.SelectAll,
            Label.SelectAnOption,
            Label.SelectMembers,
            Label.SelectVoucherCodeOrMember,
            Label.Selected,
            Label.Send,
            Label.ShareAnIdea,
            Label.ShowContent,
            Label.Sort,
            Label.SortBy,
            Label.SortByToolTip,
            Label.SpecifiedByField,
            Label.StartDateRequired,
            Label.StartsIn,
            Label.Status,
            Label.Step,
            Label.Stock,
            Label.Subject,
            Label.SubmitResponse,
            Label.SuccessfulMembersCreation,
            Label.SuccessfullyCompleted,
            Label.TableTypeRequired,
            Label.Tags,
            Label.TakeQuiz,
            Label.TargetMemberInvalidValue,
            Label.TheContactAlreadyHasAMember,
            Label.ThePointActionIsMandatory,
            Label.TheTransactionWillBeProcessedOffline,
            Label.TimezoneMissmatch,
            Label.TitleMemberPerformanceChart,
            Label.TitleRecentMembers,
            Label.TitleRecentPromotions,
            Label.TitleRecentRedemptions,
            Label.TitleRecentRewards,
            Label.TitleTimeLine,
            Label.To,
            Label.Tools,
            Label.TotalBatches,
            Label.TotalRedeemPoints,
            Label.TransactionMemberData,
            Label.TransactionOfflineProcessingStatus,
            Label.TransactionPoints,
            Label.TransactionRevertErrorGeneratedTransaction,
            Label.TransactionRevertErrorInsufficientPoints,
            Label.TransactionRevertErrorNoApproved,
            Label.TransactionRevertErrorNoProcessed,
            Label.TransactionRevertErrorTransactionReverted,
            Label.TransactionRevertSucess,
            Label.TransactionWithoutMember,
            Label.Transactions,
            Label.True,
            Label.TryAgain,
            Label.TwoAnswerOptionsRequired,
            Label.Type,
            Label.UnitPoints,
            Label.UploadFile,
            Label.UploadPhoto,
            Label.ValidateAnswerActiveModules,
            Label.ValidateAnswerFormat,
            Label.ValidateAnswerQuestionResponses,
            Label.ValidateCourseEndDate,
            Label.ValidateCourseErrorDelete,
            Label.ValidateCourseErrorSegment,
            Label.ValidateCourseErrorSubscriptionMode,
            Label.ValidateCourseStartDate,
            Label.ValidateCourseStatus,
            Label.ValidateCourseStatusErrorPredecessorIncomplete,
            Label.ValidateCourseStatusErrorSubscriptionMode,
            Label.ValidateMatchingText,
            Label.ValidateModuleActive,
            Label.ValidateModuleActiveAnswer,
            Label.ValidateModuleActiveQuestion,
            Label.ValidateModuleActiveQuestionAnswer,
            Label.ValidateModuleActiveResponses,
            Label.ValidateModuleEditableFields,
            Label.ValidateModuleResponseMemberApproved,
            Label.ValidateModuleResponseRegisteredMember,
            Label.ValidateModuleResponseSubmitted,
            Label.ValidateQuestionActiveModulesQuestions,
            Label.ValidateQuestionResponse,
            Label.ValidateQuestionResponseDelete,
            Label.ValidateQuestionResponseInsert,
            Label.ValidateQuestionResponseSubmit,
            Label.ValidationChallengeTableType,
            Label.ValidationChallengeTableType2,
            Label.ValidationChallengeTableType3,
            Label.ValidationChallengeTableType4,
            Label.ValidationChallengeTableTypeSingular,
            Label.ValidationChallengeWithoutObjective,
            Label.Value,
            Label.View,
            Label.ViewAll,
            Label.ViewCourse,
            Label.ViewModule,
            Label.ViewResults,
            Label.ViewResultsBelow,
            Label.VoucherNumber,
            Label.VouchersToRedeem,
            Label.WaitingForApproval,
            Label.WarningDeleteRewards,
            Label.Week,
            Label.WrongAnswer,
            Label.WrongLogicalExpression,
            Label.daysLeft,
            Label.security_error_field_not_insertable,
            Label.security_error_field_not_readable,
            Label.security_error_field_not_updateable,
            Label.security_error_object_not_deletable,
            Label.security_error_object_not_insertable,
            Label.security_error_object_not_readable,
            Label.security_error_object_not_updateable,
            Label.settingsExpirationPointsPartial,
            Label.settingsExpirationPointsPartialCreatedDate,
            Label.settingsExpirationPointsPartialExpirationDate,
            Label.settingsExpirationPointsTotal
        };
    }
}