const selectors = {
  pageContainer: '#project-details-page',
  breadcrumbs: '#project-details-breadcrumbs nav[aria-label="Breadcrumb"]',
  projectActions: '#project-actions',
  projectName: '#project-name',
  openProjectFolderButton: '#open-project-folder-btn',
  editProjectNameButton: '#edit-project-name-btn',
  editNameInput: '#edit-name-input',
  saveNameButton: '#save-name-btn',
  deleteProjectButton: '#delete-project-btn',
  viewProjectEventsButton: '#view-project-events-btn',
  activeProjectIndicator: '#active-project-indicator',
  setActiveProjectButton: '#set-active-project-btn',
  createUploadBundleButton: '#create-upload-bundle-btn',
  projectMetadataLink: '#project-metadata-link',
  projectTabs: '#project-tabs',
  downloadTab: '#project-tabs [data-project-tab="downloads"]',
  uploadBundleTab: (bundleId) => `#project-tabs [data-upload-bundle-id="${bundleId}"]`,
  downloadActionsCard: '#download-actions-card',
  openDownloadsFolderButton: '#open-downloads-folder-btn',
  editDownloadDirButton: '#edit-download-dir-btn',
  downloadMetadataLink: '#download-metadata-link',
  downloadSummary: '#download-summary',
  addDownloadFilesButton: '#add-download-files-btn',
  browseDatasetButton: '#browse-dataset-btn',
  downloadRepoResolver: '#download-repo-resolver',
  downloadRepoResolverForm: '#download-repo-resolver-form',
  downloadRepoResolverInput: '#download-repo-resolver_input',
  downloadRepoResolverSubmit: '#submit-download-repo-resolver-btn',
  downloadFilesList: '#download-files-list',
  downloadFilesEmpty: '#download-files-empty',
  downloadFileRows: '#download-files-list li[data-download-file-id]',
  downloadFileRowById: (fileId) => `#download-files-list li[data-download-file-id="${fileId}"]`,
  downloadFileEventsButton: (fileId) => `button[data-download-file-id="${fileId}"]`,
  retryDownloadFileButton: (fileId) => `#retry-download-file-${fileId}-btn`,
  deleteDownloadFileButton: (fileId) => `#delete-download-file-${fileId}-btn`,
  uploadBundlePane: (bundleId) => `.tab-content [data-upload-bundle-id="${bundleId}"]`,
  uploadBundleCard: (bundleId) => `#upload-bundle-${bundleId}-card`,
  uploadBundleSummary: (bundleId) => `#upload-bundle-${bundleId}-summary`,
  uploadBundleAddFilesButton: (bundleId) => `#upload-bundle-${bundleId}-add-files-btn`,
  renameUploadBundleButton: (bundleId) => `#rename-upload-bundle-${bundleId}-btn`,
  deleteUploadBundleButton: (bundleId) => `#delete-upload-bundle-${bundleId}-btn`,
  uploadBundleFilesList: (bundleId) => `#upload-bundle-${bundleId}-files`,
  uploadBundleEmptyState: (bundleId) => `#upload-bundle-${bundleId}-files-empty`,
  uploadFileRows: (bundleId) => `#upload-bundle-${bundleId}-files li[data-upload-file-id]`,
  uploadFileRowById: (bundleId, fileId) => `#upload-bundle-${bundleId}-files li[data-upload-file-id="${fileId}"]`,
  uploadFileEventsButton: (fileId) => `button[data-upload-file-id="${fileId}"]`,
  deleteUploadFileButton: (fileId) => `#delete-upload-file-${fileId}-btn`,
};

export class ProjectDetailsPage {

  assertInProjectDetails() {
    // Assert we're on the project details page
    cy.url().should('include', '/projects/')
    cy.title().should('match', /project details/i)
  }
  getPageContainer() {
    return cy.get(selectors.pageContainer);
  }

  getBreadcrumbs() {
    return cy.get(selectors.breadcrumbs);
  }

  getProjectActions() {
    return cy.get(selectors.projectActions);
  }

  getProjectName() {
    return cy.get(selectors.projectName);
  }

  clickOpenProjectFolder() {
    cy.get(selectors.openProjectFolderButton).click();
  }

  clickEditProjectName() {
    cy.get(selectors.editProjectNameButton).click();
  }

  waitClickEditProjectName() {
    cy.get(selectors.editProjectNameButton).waitClick();
  }

  getEditNameInput() {
    return cy.get(selectors.editNameInput);
  }

  typeProjectName(name) {
    this.getEditNameInput().clear().type(name);
  }

  clickSaveName() {
    cy.get(selectors.saveNameButton).click();
  }

  clickDeleteProject() {
    cy.get(selectors.deleteProjectButton).click();
  }

  clickViewProjectEvents() {
    cy.get(selectors.viewProjectEventsButton).click();
  }

  getActiveProjectIndicator() {
    return cy.get(selectors.activeProjectIndicator);
  }

  clickSetActiveProject() {
    cy.get(selectors.setActiveProjectButton).click();
  }

  clickCreateUploadBundle() {
    cy.get(selectors.createUploadBundleButton).click();
  }

  getProjectMetadataLink() {
    return cy.get(selectors.projectMetadataLink);
  }

  getTabs() {
    return cy.get(selectors.projectTabs);
  }

  getDownloadTab() {
    return cy.get(selectors.downloadTab);
  }

  clickDownloadTab() {
    this.getDownloadTab().click();
  }

  getUploadBundleTab(bundleId) {
    return cy.get(selectors.uploadBundleTab(bundleId));
  }

  clickUploadBundleTab(bundleId) {
    this.getUploadBundleTab(bundleId).click();
  }

  getDownloadActionsCard() {
    return cy.get(selectors.downloadActionsCard);
  }

  clickOpenDownloadsFolder() {
    cy.get(selectors.openDownloadsFolderButton).click();
  }

  clickEditDownloadDirectory() {
    cy.get(selectors.editDownloadDirButton).click();
  }

  getDownloadMetadataLink() {
    return cy.get(selectors.downloadMetadataLink);
  }

  getDownloadSummary() {
    return cy.get(selectors.downloadSummary);
  }

  clickAddDownloadFiles() {
    cy.get(selectors.addDownloadFilesButton).click();
  }

  toggleBrowseDataset() {
    cy.get(selectors.browseDatasetButton).click();
  }

  getDownloadRepoResolver() {
    return cy.get(selectors.downloadRepoResolver);
  }

  getDownloadRepoResolverForm() {
    return cy.get(selectors.downloadRepoResolverForm);
  }

  getDownloadRepoResolverInput() {
    return cy.get(selectors.downloadRepoResolverInput);
  }

  submitDownloadRepoResolver() {
    cy.get(selectors.downloadRepoResolverSubmit).click();
  }

  getDownloadFilesList() {
    return cy.get(selectors.downloadFilesList);
  }

  getDownloadFilesEmptyState() {
    return cy.get(selectors.downloadFilesEmpty);
  }

  getDownloadFileRows() {
    return cy.get(selectors.downloadFileRows);
  }

  getDownloadFileRowById(fileId) {
    return cy.get(selectors.downloadFileRowById(fileId));
  }

  getDownloadFileEventsButton(fileId) {
    return cy.get(selectors.downloadFileEventsButton(fileId));
  }

  clickRetryDownloadFile(fileId) {
    cy.get(selectors.retryDownloadFileButton(fileId)).click();
  }

  clickDeleteDownloadFile(fileId) {
    cy.get(selectors.deleteDownloadFileButton(fileId)).click();
  }

  getUploadBundlePane(bundleId) {
    return cy.get(selectors.uploadBundlePane(bundleId));
  }

  getUploadBundleCard(bundleId) {
    return cy.get(selectors.uploadBundleCard(bundleId));
  }

  getUploadBundleSummary(bundleId) {
    return cy.get(selectors.uploadBundleSummary(bundleId));
  }

  clickUploadBundleAddFiles(bundleId) {
    cy.get(selectors.uploadBundleAddFilesButton(bundleId)).click();
  }

  clickRenameUploadBundle(bundleId) {
    cy.get(selectors.renameUploadBundleButton(bundleId)).click();
  }

  clickDeleteUploadBundle(bundleId) {
    cy.get(selectors.deleteUploadBundleButton(bundleId)).click();
  }

  getUploadBundleFilesList(bundleId) {
    return cy.get(selectors.uploadBundleFilesList(bundleId));
  }

  getUploadBundleEmptyState(bundleId) {
    return cy.get(selectors.uploadBundleEmptyState(bundleId));
  }

  getUploadFileRows(bundleId) {
    return cy.get(selectors.uploadFileRows(bundleId));
  }

  getUploadFileRowById(bundleId, fileId) {
    return cy.get(selectors.uploadFileRowById(bundleId, fileId));
  }

  getUploadFileEventsButton(fileId) {
    return cy.get(selectors.uploadFileEventsButton(fileId));
  }

  clickDeleteUploadFile(fileId) {
    cy.get(selectors.deleteUploadFileButton(fileId)).click();
  }
}

export default new ProjectDetailsPage();
