function GetControl(controlID)
{
    var control = document.getElementById(controlID);
    if (control == null)
        alert("Unable to locate control: " + controlID);
    
    return control;
}

function IsIEBrowser()
{
	if (navigator.appName.indexOf("Microsoft") != -1)
		return true;
	else
		return false;
}

function ToggleInputImageSrc(inputCtrlID, enabledImage, disabledImage, enabled)
{
    var inputCtrl = document.getElementById(inputCtrlID);
    if (enabled)
        inputCtrl.src = enabledImage;
    else
        inputCtrl.src = disabledImage;
}

// Params area object constructor
function RSParameters(disabledColor, disabledStyle, enabledStyle, parametersGridID, credentialLinkID)
{
    this.m_disabledColor = disabledColor;
    this.m_disabledStyle = disabledStyle;
    this.m_enabledStyle = enabledStyle;
    this.m_parametersGridID = parametersGridID;
    this.m_credentialLinkID = credentialLinkID;
}

// Update the state of a nullable parameter.
function UpdateParam1(nullChkID, param1ID)
{
    this.UpdateParam2(nullChkID, param1ID, null);
}
RSParameters.prototype.UpdateParam1 = UpdateParam1;

function UpdateParam2(nullChkID, param1ID, param2ID)
{
    if (!IsIEBrowser)
        return;
        
    // Get the interesting controls
    var nullChkBox = GetControl(nullChkID);
    if (nullChkBox == null)
        return;
    var param1Control = GetControl(param1ID);
    if (param1Control == null)
        return;
    var param2Control = null;
    if (param2ID != null)
    {
        param2Control = GetControl(param2ID);
        if (param2Control == null)
            return;
    }        

	// If the null checkbox itself is not enabled, don't change the state
	// of the parameter controls.  The null check box is disabled when
	// a data driven parameter has an outstanding dependencies
	if (nullChkBox.disabled)
		return;

    // Enable/Disable the other controls
    this.DisableInput(param1Control, nullChkBox.checked);
    if (param2Control != null)
        this.DisableInput(param2Control, nullChkBox.checked);
}
RSParameters.prototype.UpdateParam2 = UpdateParam2;

function DisableInput(control, shouldDisable)
{
    if (control.type == "text")         // Enable/disable a text box
    {
        this.DisableTextInput(control, shouldDisable);
    }
    else if (control.type == "radio")   // Enable/disable a radio button
    {
        // ASP sets the disabled tag on a span that contains the radio button
        control.parentNode.disabled = shouldDisable;    
    }
    else
        control.disabled = shouldDisable;
}
RSParameters.prototype.DisableInput = DisableInput;

function DisableReportViewerTextInput(control, shouldDisable)
{
    var useClass = this.m_disabledStyle != "" || this.m_enabledStyle != "";
    if (shouldDisable)
    {
        if (useClass)
            control.className = this.m_disabledStyle;
        else
	        control.style.backgroundColor = this.m_disabledColor;
    }
    else
    {
        if (useClass)
            control.className = this.m_enabledStyle;
        else
	        control.style.backgroundColor = "";
    }
    
    control.disabled = shouldDisable;
}
RSParameters.prototype.DisableTextInput = DisableReportViewerTextInput;

function RSP_HideActiveDropDown()
{
    if (this.ActiveDropDown != null)
        this.ActiveDropDown.Hide();
}
RSParameters.prototype.HideActiveDropDown = RSP_HideActiveDropDown;

function RSP_OnActiveDropDownHidden(previouslyVisibleDropDown)
{
    // Check that it is still listed as active, in case event ordering
    // caused the show on the new one to fire first
    if (this.ActiveDropDown == previouslyVisibleDropDown)
        this.ActiveDropDown = null;
}
RSParameters.prototype.OnActiveDropDownHidden = RSP_OnActiveDropDownHidden;

function RSP_SetNewActiveDropDown(newDropDown)
{
    // Hide the previously visible dropDown
    if (this.ActiveDropDown != newDropDown && this.ActiveDropDown != null)
        this.ActiveDropDown.Hide();

    this.ActiveDropDown = newDropDown;
}
RSParameters.prototype.SetNewActiveDropDown = RSP_SetNewActiveDropDown;

function OnChangeCredentialsClicked()
{
    // Hide the link
    event.srcElement.style.display = "none";
    
    // Make sure each row in the table is visible
    var paramsTable = GetControl(this.m_parametersGridID);
    for (var i = 0; i < paramsTable.rows.length; i++)
    {
        var row = paramsTable.rows[i];
        if (row.IsParameterRow != "true")
            row.style.display = "inline";
        else
            row.style.display = "none";
    }
}
RSParameters.prototype.OnChangeCredentialsClicked = OnChangeCredentialsClicked;

function ShouldValidateCredentials()
{
    // Get the credential link
    var credentialLink = document.getElementById(this.m_credentialLinkID);
    
    // The credential link is not rendered in 2 cases.
    // 1 - There are no credentials.  This method is only called when validating
    //     credentials.  So this method won't get called in this case.
    // 2 - The credential prompts are being shown initially because they aren't
    //     satisfied.  In this case, we always want to validate the input boxes.
    if (credentialLink == null)
        return true;

    // Switched back from intial view of parameters to credentials
    return credentialLink.style.display == "none";
}
RSParameters.prototype.ShouldValidateCredentials = ShouldValidateCredentials;

function ShouldValidateParameters()
{
    // Get the credential link
    var credentialLink = document.getElementById(this.m_credentialLinkID);
    // The credential link is not rendered in 2 cases.
    // 1 - There are no credentials.  This method is only called when validating
    //     parameters.  If there are no credentials, the parameters must be visible
    //     and should be validated
    // 2 - The credential prompts are being shown initially because they aren't
    //     satisfied.  In this case, there are no rendered parameter prompts, so
    //     this method won't get called.
    if (credentialLink == null)
        return true;

    // Initial view was of parameters and it still is
    return credentialLink.style.display != "none";
}
RSParameters.prototype.ShouldValidateParameters = ShouldValidateParameters;

function ValidateCredential(userID, errMsg)
{
    // If the credentials are not visible, we don't need to validate them.
    if (!this.ShouldValidateCredentials())
        return true;
        
    var userControl = GetControl(userID);
    if (userControl.value == "")
    {
        alert(errMsg);
        return false;
    }
    return true;
}
RSParameters.prototype.ValidateCredential = ValidateCredential;

// Validate that the parameter has a non-empty value
function ValidateHasValue(paramID, nullChkID, errmsg)
{
    // If the parameters are not visible, we don't need to validate them.
    if (!this.ShouldValidateParameters())
        return true;

	if (nullChkID != "" && (document.getElementById(nullChkID).checked == true))
		return true;
	var paramValue = document.getElementById(paramID).value;
	if ((paramValue == null) || (paramValue == ""))
	{
		alert(errmsg);
		return false;
	}
	return true;
}
RSParameters.prototype.ValidateHasValue = ValidateHasValue;

function DoesInputHaveValue(elementID)
{
    var element = document.getElementById(elementID);
    
    if (element.value != null && element.value != "")
        return true;
    
    return false;
}
RSParameters.prototype.DoesInputHaveValue = DoesInputHaveValue;

function DoesBooleanHaveValue(trueID, falseID)
{
    var trueElement = document.getElementById(trueID);
    var falseElement = document.getElementById(falseID);
    
    if (trueElement.checked || falseElement.checked)
        return true;
    
    return false;
}
RSParameters.prototype.DoesBooleanHaveValue = DoesBooleanHaveValue;

// Validate a drop down list
function ValidateDropDown(paramID, errMsg, hasInitialBlank)
{
    // If the parameters are not visible, we don't need to validate them.
    if (!this.ShouldValidateParameters())
        return true;

	// The first item is a blank place holder
	if (hasInitialBlank)
	{
		var dropDown = document.getElementById(paramID);
		if (dropDown.selectedIndex == 0)
		{
			alert(errMsg);
			return false;
		}
	}
	
	return true;
}
RSParameters.prototype.ValidateDropDown = ValidateDropDown;

function ValidateBoolean(trueID, falseID, nullChkID, errmsg)
{
    // If the parameters are not visible, we don't need to validate them.
    if (!this.ShouldValidateParameters())
        return true;

	if (nullChkID != "" && (document.getElementById(nullChkID).checked == true))
		return true;
	var trueChecked = document.getElementById(trueID).checked;
	var falseChecked = document.getElementById(falseID).checked;
	if (!trueChecked && !falseChecked)
	{
		alert(errmsg);
		return false;
	}
	return true;
}
RSParameters.prototype.ValidateBoolean = ValidateBoolean;

// Report class constructor
function RSReport(clientController, reportPrefix, reportDivID, reportCellID, initialZoomValue, navigationId, pageNumber, totalPages,
                  hasDocMap, searchStartPage, autoRefreshAction, autoRefreshInterval, searchText)
{
    this.m_clientController = clientController;
    this.m_reportPrefix = reportPrefix;
    this.m_reportDivID = reportDivID;
    this.m_reportCellID = reportCellID;
    this.m_initialZoomValue = initialZoomValue;
    this.m_navigationId = navigationId;
    this.m_pageNumber = pageNumber;
    this.m_totalPages = totalPages;
    this.m_hasDocMap = hasDocMap;
    this.m_nextHit = 1;
    this.m_searchStartPage = searchStartPage;
    this.m_autoRefreshAction = autoRefreshAction;
    this.m_autoRefreshInterval = autoRefreshInterval;
    this.m_searchText = searchText;
}

function OnLoadReport(reloadDocMap)
{
    this.m_clientController.OnReportLoaded(this, reloadDocMap);

    if (null != this.m_navigationId && this.m_navigationId != "")
        window.location.replace("#" + this.m_navigationId);
        
    if (this.m_autoRefreshAction != null)
        setTimeout(this.m_autoRefreshAction, this.m_autoRefreshInterval);
}
RSReport.prototype.OnLoadReport = OnLoadReport;

function UpdateZoom(paramZoomValue)
{
    if (paramZoomValue != null)
        zoomValue = paramZoomValue;
    else if (this.m_lastZoomValue != null)
        zoomValue = this.m_lastZoomValue;
    else
        // Zoom should be set initially during OnLoad.  Until then, ignore calls from toolbar/resize event
        return;

    // Get the report cell
	var reportCell = GetControl(this.m_reportCellID);
	if (reportCell == null)
	    return;

	if ((zoomValue != "PageWidth") && (zoomValue != "FullPage"))
		reportCell.style.zoom = zoomValue + "%";
	else
	{
	    // Get the report div
	    var reportDiv = GetControl(this.m_reportDivID);
	    if (reportDiv == null)
	        return;
	    
		if (zoomValue != "PageWidth")
		{
			if ((reportCell.offsetWidth * reportDiv.offsetHeight) < (reportCell.offsetHeight * reportDiv.offsetWidth))
				SetZoom(reportCell, reportDiv.offsetHeight, reportCell.offsetHeight);
			else
				SetZoom(reportCell, reportDiv.offsetWidth, reportCell.offsetWidth);
		}
		else
		{
			var vbar = reportDiv.offsetHeight != reportDiv.clientHeight;
			var proceed = (reportCell.offsetWidth > 0);
			for (var iter = 0; (iter <= 1) & proceed; ++iter)
			{
				zoomValue = SetZoom(reportCell, reportDiv.clientWidth, reportCell.offsetWidth);
				proceed = vbar != ((reportCell.offsetHeight * zoomValue) > reportDiv.offsetHeight);
			}
		}
	}
	
	if (paramZoomValue != null)
        this.m_lastZoomValue = paramZoomValue;
}
RSReport.prototype.UpdateZoom = UpdateZoom;

function ActionHandler(actionType, actionParam)
{
    var completeActionParam;
    if (actionType == "Sort")    
    {
        if (window.event && window.event.shiftKey) 
            completeActionParam = actionParam + "_T";
        else
            completeActionParam = actionParam + "_F";
    }
    else
        completeActionParam = actionParam;
        
    return this.m_clientController.ActionHandler(actionType, completeActionParam);
}
RSReport.prototype.ActionHandler = ActionHandler;

// Zoom to the ratio specified by div / rep.
function SetZoom(reportCell, div, rep)
{
	if (rep <= 0)
		return 1.0;
	var z = (div - 1) / rep;
	reportCell.style.zoom = z;
	return z;
}

function ReportFindNext ()
{
	// Unhighlight previous hit, if any.
	if (this.m_nextHit > 0)
	{
		var hitElem = document.getElementById(this.m_reportPrefix + "oHit" + (this.m_nextHit - 1));
		if (hitElem != null)
		{
			hitElem.style.backgroundColor = "";
			hitElem.style.color = "";
		}
	}

    // Highlight current hit and navigate to it.
	var hitElem = document.getElementById(this.m_reportPrefix + "oHit" + this.m_nextHit);
	if (hitElem == null)
	    return false;
	hitElem.style.backgroundColor = "highlight";
	hitElem.style.color = "highlighttext";
	window.location.replace("#" + this.m_reportPrefix + "oHit" + this.m_nextHit);

    this.m_nextHit ++;

    return true;
}
RSReport.prototype.FindNext = ReportFindNext

function OnFrameVisible()
{
    // In async mode, fit proportional must happen after the report frame
    // becomes visible, otherwise images dimensions are 0.  In sync mode
    // it is handled inline in the renderer.
    if (typeof(ResizeImages) == "function") // Make sure it is defined
        ResizeImages();

    this.UpdateZoom(this.m_initialZoomValue);    
}
RSReport.prototype.OnFrameVisible = OnFrameVisible

// The client side viewer controller
function RSClientController(waitControlID, docMapReportFrameID, docMapUrl, docMapSize,
                            docMapVisible, baseReportPageUrl, canHandlePageNavOnClient, canHandleToggleOnClient,
                            canHandleSortOnClient, canHandleBookmarkOnClient, canHandleDocMapOnClient,
                            canHandleSearchOnClient, clientCurrentPageID,
                            canHandleRefreshOnClient, exportUrlBase, printFrameId, printHtmlLink,
                            docMapVisibilityStateID, promptAreaRowId, promptVisibilityStateId)
{
    this.m_waitControlID = waitControlID;
    this.m_docMapReportFrameID = docMapReportFrameID;
    this.m_docMapUrl = docMapUrl;
    this.m_docMapSize = docMapSize;
    this.m_docMapVisible = docMapVisible;
    this.m_baseReportPageUrl = baseReportPageUrl;
    this.m_canHandlePageNavOnClient = canHandlePageNavOnClient;
    this.m_canHandleToggleOnClient = canHandleToggleOnClient;
    this.m_canHandleSortOnClient = canHandleSortOnClient;
    this.m_canHandleBookmarkOnClient = canHandleBookmarkOnClient;
    this.m_canHandleDocMapOnClient = canHandleDocMapOnClient;
    this.m_canHandleRefreshOnClient = canHandleRefreshOnClient;
    this.m_clientCurrentPageID = clientCurrentPageID;
    this.m_canHandleSearchOnClient = canHandleSearchOnClient;
    this.m_exportUrlBase = exportUrlBase;
    this.m_printFrameId = printFrameId;
    this.m_printHtmlLink = printHtmlLink;
    this.m_docMapVisibilityStateID = docMapVisibilityStateID;
    this.m_promptAreaRowId = promptAreaRowId;
    this.m_promptVisibilityStateId = promptVisibilityStateId;
    this.m_reportLoaded = false;

    // Calculated property    
    if (this.m_docMapReportFrameID == "")
        this.IsAsync = false;
    else
        this.IsAsync = true;
}

function ControllerActionHandler(actionType, actionParam)
{
    // Don't allow empty search
    if ((actionType == "Search" || actionType == "SearchNext") &&
        (actionParam == null || actionParam == ""))
        return;

    if (this.CanHandleClientSideAction(actionType))
    {
        // Construct the url
        var actionUrl = this.m_baseReportPageUrl + "&" + this.CommonReportPageQueryParams();
        actionUrl += "&ActionType=" + encodeURIComponent(actionType);
        actionUrl += "&ActionParam=" + encodeURIComponent(actionParam);
        if (this.CurrentPage != null)
            actionUrl += "&PageNumber=" + encodeURIComponent(this.CurrentPage);
        
        // Sort can change the document map
        if (actionType == "Sort")
            actionUrl += "&ReloadDocMap=" + "true";

        // Set report frame
        this.PerformClientSidePageChange(actionUrl);
    }
    else
        return this.PostBackAction(actionType, actionParam);
}
RSClientController.prototype.ActionHandler = ControllerActionHandler;

function CanHandleClientSideAction(actionType)
{
    if (actionType == "Toggle")
        return this.m_canHandleToggleOnClient;
    else if (actionType == "Bookmark")
        return this.m_canHandleBookmarkOnClient;
    else if (actionType == "DocumentMap")
        return this.m_canHandleDocMapOnClient;
    else if (actionType == "Sort")
        return this.m_canHandleSortOnClient;
    else if (actionType == "Search")
        return this.m_canHandleSearchOnClient;
    else if (actionType == "SearchNext")
        return this.m_canHandleSearchOnClient;
    else if (actionType == "Refresh")
        return this.m_canHandleRefreshOnClient;
    else if (actionType == "PageNav")
        return this.m_canHandlePageNavOnClient;
    else
        return false; // Drillthrough
}
RSClientController.prototype.CanHandleClientSideAction = CanHandleClientSideAction;

function OnReportLoaded(reportObject, reloadDocMap)
{
    this.m_reportObject = reportObject;
    this.CurrentPage = reportObject.m_pageNumber;
    this.TotalPages = reportObject.m_totalPages;
    this.m_searchStartPage = reportObject.m_searchStartPage;

    // Update the client side page number so that it is available to the server object
    // if it was changed asynchronously.
    var clientCurrentPage = GetControl(this.m_clientCurrentPageID);
    if (clientCurrentPage != null)
        clientCurrentPage.value = this.CurrentPage;
    
    // If there is a document map, display it
    if (this.HasDocumentMap())
    {
        // This method is called each time the report loads.  This happens
        // for page navigations and report actions.  For many of these cases,
        // the doc map didn't change, so don't reload it.
        if (reloadDocMap)
        {
            if (this.CanDisplayBuiltInDocMap() && this.m_docMapUrl != "")
            {
                var docMapReportFrame = frames[this.m_docMapReportFrameID];
                docMapReportFrame.frames["docmap"].location.replace(this.m_docMapUrl);
            }

            this.CustomOnReloadDocMap();
        }

        if (this.m_docMapVisible && this.CanDisplayBuiltInDocMap())
            this.SetDocMapVisibility(true);
    }
    
    this.CustomOnReportLoaded();
}
RSClientController.prototype.OnReportLoaded = OnReportLoaded;

function OnReportFrameLoaded()
{
	this.m_reportLoaded = true;
    this.ShowWaitFrame(false);
 
    if (this.IsAsync && this.m_reportObject != null)
        this.m_reportObject.OnFrameVisible();
}
RSClientController.prototype.OnReportFrameLoaded = OnReportFrameLoaded;

function RVCC_CanDisplayBuiltInDocMap()
{
    return this.IsAsync;
}
RSClientController.prototype.CanDisplayBuiltInDocMap = RVCC_CanDisplayBuiltInDocMap;

function RVCC_HasDocumentMap()
{
    if (this.m_reportObject != null)
        return this.m_reportObject.m_hasDocMap;
    else
        return false;
}
RSClientController.prototype.HasDocumentMap = RVCC_HasDocumentMap;

function DelegateZoomChange(zoomValue)
{
    this.m_reportObject.UpdateZoom(zoomValue);
    
    // Set the zoom value to the last one on the report object instead
    // of the parameter so that it only gets set if it is valid.
    this.m_zoomValue = this.m_reportObject.m_lastZoomValue;
}
RSClientController.prototype.SetZoom = DelegateZoomChange;

function RSCC_CurrentZoom()
{
    var zoomValue = null;
    if (this.m_zoomValue != null)
        zoomValue = this.m_zoomValue; // Might be null if zoom was never changed on the client
    if (zoomValue == null && this.m_reportObject != null)
        zoomValue = this.m_reportObject.m_initialZoomValue;
    if (zoomValue == null)
        zoomValue = "100";
    
    return zoomValue;
}
RSClientController.prototype.CurrentZoom = RSCC_CurrentZoom;

function ShowInitialWaitFrame()
{
	if (!this.m_reportLoaded)
		this.ShowWaitFrame(true);
}
RSClientController.prototype.ShowInitialWaitFrame = ShowInitialWaitFrame;

function ShowWaitFrame(startShowingWaitFrame)
{
    // Check for synchronous processing
    if (!this.IsAsync)
        return;
        
    var waitControl = document.getElementById(this.m_waitControlID);
    if (!waitControl)
        return;

    var reportFrame = GetControl(this.m_docMapReportFrameID);
    
    if (startShowingWaitFrame)
    {
        waitControl.style.display = "inline";
        reportFrame.style.display = "none";
    }
    else
    {
        waitControl.style.display = "none";
        reportFrame.style.display = "inline";
    }
}
RSClientController.prototype.ShowWaitFrame = ShowWaitFrame;

function SetDocMapVisibility(makeVisible)
{
    var docMapReportFrame = frames[this.m_docMapReportFrameID];
    var frameset = docMapReportFrame.GetFrameSet();
    var reportFrame = docMapReportFrame.GetReportFrame();
    var docMapVisibilityState = document.getElementById(this.m_docMapVisibilityStateID);

    if (makeVisible)
    {
        frameset.cols = this.m_docMapSize + ",*";
        frameset.frameSpacing = "3";
        reportFrame.noResize = null;
        docMapVisibilityState.value = "false";
    }
    else
    {
        frameset.cols = "0,*";
        frameset.frameSpacing = "0";
        reportFrame.noResize = "true";
        docMapVisibilityState.value = "true";
    }

    this.m_docMapVisible = makeVisible;

    this.CustomOnDocMapVisibilityChange();
}
RSClientController.prototype.SetDocMapVisibility = SetDocMapVisibility;

function IsDocMapVisible()
{
    var docMapReportFrame = frames[this.m_docMapReportFrameID];
    if (docMapReportFrame == null)
        return false;

    var reportFrame = docMapReportFrame.GetReportFrame();
    if (reportFrame == null)
        return false;

	return !reportFrame.noResize;
}
RSClientController.prototype.IsDocMapVisible = IsDocMapVisible;

function RSCC_HandleSearchNext()
{
    if (this.m_reportObject != null)
    {
        if (!this.m_reportObject.FindNext())
            this.ActionHandler("SearchNext", this.m_searchStartPage + "_" + this.m_reportObject.m_searchText);
    }
}
RSClientController.prototype.HandleSearchNext = RSCC_HandleSearchNext;

function RSCC_CanContinueSearch()
{
    if (this.m_reportObject != null)
        return this.m_reportObject.m_searchStartPage > 0;
    else
        return false;
}
RSClientController.prototype.CanContinueSearch = RSCC_CanContinueSearch;

function PerformClientSidePageChange(url)
{
    this.CustomOnAsyncPageChange();

    // Get the report frame and set the url
    var docMapReportFrame = frames[this.m_docMapReportFrameID];
    var reportFrame = docMapReportFrame.frames["report"];
    this.m_reportObject = null; // We are changing the frame content.  The report object will be freed automatically.
    reportFrame.location.replace(url);
}
RSClientController.prototype.PerformClientSidePageChange = PerformClientSidePageChange;

function CommonReportPageQueryParams()
{
    var zoomValue = this.CurrentZoom();
    var zoomMode = "Percent";
    var zoomPercent = "100";        
    if (zoomValue == "PageWidth" || zoomValue == "FullPage")
        zoomMode = zoomValue;
    else
        zoomPercent = zoomValue;
        
    return "&ZoomMode=" + encodeURIComponent(zoomMode) + "&ZoomPct=" + encodeURIComponent(zoomPercent);
}
RSClientController.prototype.CommonReportPageQueryParams = CommonReportPageQueryParams;

function RSCC_LoadPrintControl()
{
    var printFrame = document.getElementById(this.m_printFrameId);
    if (printFrame != null)
    {
        if (printFrame.src != this.m_printHtmlLink)
            window.frames[this.m_printFrameId].window.location.replace(this.m_printHtmlLink);
        else
            eval(this.m_printFrameId + ".Print();");
    }
    
    return false;
}
RSClientController.prototype.LoadPrintControl = RSCC_LoadPrintControl;

function RSCC_SetPromptAreaVisibility(makeVisible)
{
    var parametersRow = document.getElementById(this.m_promptAreaRowId);
    if (parametersRow == null)
        return;
    var promptVisibilityState = document.getElementById(this.m_promptVisibilityStateId);

    if (makeVisible)
    {
        parametersRow.style.display = "";
        promptVisibilityState.value = "false";
    }
    else
    {
        parametersRow.style.display = "none";
        promptVisibilityState.value = "true";
    }

    this.CustomOnPromptAreaVisibilityChange();
}
RSClientController.prototype.SetPromptAreaVisibility = RSCC_SetPromptAreaVisibility;

function RSCC_ArePromptsVisible()
{
    var promptVisibilityState = document.getElementById(this.m_promptVisibilityStateId);
    return promptVisibilityState.value == "false";
}
RSClientController.prototype.ArePromptsVisible = RSCC_ArePromptsVisible;



// Link class constructor
function ReportViewerLink(linkID, initialActive, activeLinkStyle, disabledLinkStyle, activeLinkColor,
    disabledLinkColor, activeHoverLinkColor)
{
    this.m_linkID = linkID;
    this.m_isActive = initialActive;
    this.m_activeLinkStyle = activeLinkStyle;
    this.m_disabledLinkStyle = disabledLinkStyle;
    this.m_activeLinkColor = activeLinkColor;
    this.m_disabledLinkColor = disabledLinkColor;
    this.m_activeHoverLinkColor = activeHoverLinkColor;
    
    if (this.m_activeLinkStyle != "")
        this.m_isUsingStyles = true;
    else
        this.m_isUsingStyles = false;
}

function ReportViewerLinkIsViewerLinkActive()
{
    return this.m_isActive;
}
ReportViewerLink.prototype.IsViewerLinkActive = ReportViewerLinkIsViewerLinkActive;

function ReportViewerLinkSetViewerLinkActive(isActive)
{
    var button = GetControl(this.m_linkID);
    if (button == null)
        return;
        
    this.m_isActive = isActive;
    
    // If using styles, update style name
    if (this.m_isUsingStyles)
    {
        if (this.m_isActive)
            button.className = this.m_activeLinkStyle;
        else
            button.className = this.m_disabledLinkStyle;
    }
    
    this.OnLinkNormal();
}
ReportViewerLink.prototype.SetViewerLinkActive = ReportViewerLinkSetViewerLinkActive;

function ReportViewerLinkOnLinkHover()
{
    if (this.m_isUsingStyles)
        return;
        
    var link = GetControl(this.m_linkID);
    if (link == null)
        return;

    if (this.m_isActive)
    {
        link.style.textDecoration = "underline";
        link.style.color = this.m_activeHoverLinkColor;
        link.style.cursor = "pointer";
    }
    else
        link.style.cursor = "default";
}
ReportViewerLink.prototype.OnLinkHover = ReportViewerLinkOnLinkHover;

function ReportViewerLinkOnLinkNormal()
{
    if (this.m_isUsingStyles)
        return;

    var link = GetControl(this.m_linkID);
    if (link == null)
        return;

    if (this.m_isActive)
        link.style.color = this.m_activeLinkColor;
    else
        link.style.color = this.m_disabledLinkColor;
    link.style.textDecoration = "none";
}
ReportViewerLink.prototype.OnLinkNormal = ReportViewerLinkOnLinkNormal;







function ReportViewerHoverButton(buttonID, isPressed, normalStyle, hoverStyle, hoverPressedStyle, normalColor,
    hoverColor, hoverPressedColor, normalBorder, hoverBorder, hoverPressedBorder)
{
    this.m_buttonID = buttonID;
    this.m_isPressed = isPressed;
    this.m_normalStyle = normalStyle;
    this.m_hoverStyle = hoverStyle;
    this.m_hoverPressedStyle = hoverPressedStyle;
    this.m_normalColor = normalColor;
    this.m_hoverColor = hoverColor;
    this.m_hoverPressedColor = hoverPressedColor;
    this.m_normalBorder = normalBorder;
    this.m_hoverBorder = hoverBorder;
    this.m_hoverPressedBorder = hoverPressedBorder;

    if (this.m_normalStyle != "")
        this.m_isUsingStyles = true;
    else
        this.m_isUsingStyles = false;
}

function ReportViewerHoverButtonOnHover()
{
    var button = GetControl(this.m_buttonID);
    if (button == null)
        return;

    if (this.m_isUsingStyles)
        button.className = this.m_isPressed ? this.m_hoverPressedStyle : this.m_hoverStyle;
    else
    {
        button.style.border = this.m_isPressed ? this.m_hoverPressedBorder : this.m_hoverBorder;
        button.style.backgroundColor = this.m_isPressed ? this.m_hoverPressedColor : this.m_hoverColor;
        button.style.cursor = "pointer";
    }
}
ReportViewerHoverButton.prototype.OnHover = ReportViewerHoverButtonOnHover;

function ReportViewerHoverButtonOnNormal()
{
    var button = GetControl(this.m_buttonID);
    if (button == null)
        return;

    if (this.m_isUsingStyles)
        button.className = this.m_isPressed ? this.m_hoverStyle : this.m_normalStyle;
    else
    {
        button.style.border = this.m_isPressed ? this.m_hoverBorder : this.m_normalBorder;
        button.style.backgroundColor = this.m_isPressed ? this.m_hoverColor : this.m_normalColor;
        button.style.cursor = "default";
    }
}
ReportViewerHoverButton.prototype.OnNormal = ReportViewerHoverButtonOnNormal;

function ReportViewerHoverButtonSetPressed(isPressed)
{
    this.m_isPressed = isPressed;
    this.OnNormal();
}
ReportViewerHoverButton.prototype.SetPressed = ReportViewerHoverButtonSetPressed;







function RVTB_SetHasDocMap(docMapGroupId)
{
    var docMapGroup = document.getElementById(docMapGroupId);
    if (docMapGroup != null)
    {
        // Make the button visible
        docMapGroup.style.display = "inline";
        
        // Make sure there is a spacer (there won't be in the docmap is the only button), and make it visible
        var docMapSpacer = docMapGroup.nextSibling;
        if (docMapSpacer != null && docMapSpacer.ToolbarSpacer == "true")
            docMapSpacer.style.display = "inline";
    }
}
