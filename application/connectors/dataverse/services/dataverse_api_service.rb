class DataverseApiService
    include LoggingCommon
    include DateTimeCommon

    AUTH_HEADER = 'X-Dataverse-key'
    class UnauthorizedException < Exception; end
    class ApiKeyRequiredException < Exception; end
end
