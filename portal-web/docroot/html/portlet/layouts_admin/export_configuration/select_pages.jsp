<%--
/**
 * Copyright (c) 2000-2013 Liferay, Inc. All rights reserved.
 *
 * This library is free software; you can redistribute it and/or modify it under
 * the terms of the GNU Lesser General Public License as published by the Free
 * Software Foundation; either version 2.1 of the License, or (at your option)
 * any later version.
 *
 * This library is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public License for more
 * details.
 */
--%>

<%@ include file="/html/portlet/layouts_admin/init.jsp" %>

<%
String cmd = ParamUtil.getString(request, Constants.CMD);

long groupId = ParamUtil.getLong(request, "groupId");

Group group = null;

if (groupId > 0) {
	group = GroupLocalServiceUtil.getGroup(groupId);
}

long layoutSetBranchId = ParamUtil.getLong(request, "layoutSetBranchId");

boolean privateLayout = ParamUtil.getBoolean(request, "privateLayout");

String treeId = ParamUtil.getString(request, "treeId");

long[] selectedLayoutIds = StringUtil.split(ParamUtil.getString(request, "selectedLayoutIds"), 0L);
%>

<aui:input name="layoutIds" type="hidden" />

<span class="selected-labels" id="<portlet:namespace />selectedPages"></span>

<aui:a cssClass="modify-link" href="javascript:;" id="pagesLink" label="change" method="get" />

<div class="hide" id="<portlet:namespace />pages">
	<aui:fieldset cssClass="portlet-data-section" label="pages-to-export">
		<div class="alert alert-info">
			<liferay-ui:message key="note-that-selecting-no-pages-from-tree-reverts-to-implicit-selection-of-all-pages" />
		</div>

		<div class="selected-pages" id="<portlet:namespace />pane">
			<liferay-util:include page="/html/portlet/layouts_admin/tree_js.jsp">
				<liferay-util:param name="tabs1" value='<%= privateLayout ? "private-pages" : "public-pages" %>' />
				<liferay-util:param name="incomplete" value="<%= Boolean.FALSE.toString() %>" />
				<liferay-util:param name="treeId" value="<%= treeId %>" />
				<liferay-util:param name="defaultStateChecked" value="1" />
				<liferay-util:param name="selectableTree" value="1" />
			</liferay-util:include>
		</div>

		<c:if test="<%= cmd.equals(Constants.PUBLISH) %>">
			<aui:input name="scope" type="hidden" value='<%= ArrayUtil.isEmpty(selectedLayoutIds) ? "all-pages" : "selected-pages" %>' />

			<c:choose>
				<c:when test="<%= layoutSetBranchId > 0 %>">
					<aui:input name="layoutSetBranchId" type="hidden" value="<%= layoutSetBranchId %>" />
				</c:when>
				<c:otherwise>
					<c:if test="<%= LayoutStagingUtil.isBranchingLayoutSet(group, privateLayout) %>">

						<%
						List<LayoutSetBranch> layoutSetBranches = LayoutSetBranchLocalServiceUtil.getLayoutSetBranches(group.getGroupId(), privateLayout);
						%>

						<aui:select label="site-pages-variation" name="layoutSetBranchId">

							<%
							for (LayoutSetBranch layoutSetBranch : layoutSetBranches) {
								boolean selected = false;

								if (layoutSetBranch.isMaster()) {
									selected = true;
								}
							%>

								<aui:option label="<%= HtmlUtil.escape(layoutSetBranch.getName()) %>" selected="<%= selected %>" value="<%= layoutSetBranch.getLayoutSetBranchId() %>" />

							<%
							}
							%>

						</aui:select>
					</c:if>
				</c:otherwise>
			</c:choose>

			<aui:input helpMessage="delete-missing-layouts-staging-help" label="delete-missing-layouts" name="<%= PortletDataHandlerKeys.DELETE_MISSING_LAYOUTS %>" type="checkbox" />
		</c:if>

		<aui:input label="site-pages-settings" name="<%= PortletDataHandlerKeys.LAYOUT_SET_SETTINGS %>" type="checkbox" value="<%= true %>" />
	</aui:fieldset>

	<aui:fieldset cssClass="portlet-data-section" label="look-and-feel">
		<aui:input helpMessage="export-import-theme-settings-help" label="theme-settings" name="<%= PortletDataHandlerKeys.THEME_REFERENCE %>" type="checkbox" value="<%= true %>" />

		<aui:input label="logo" name="<%= PortletDataHandlerKeys.LOGO %>" type="checkbox" value="<%= true %>" />
	</aui:fieldset>
</div>