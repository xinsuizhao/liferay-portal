<#include "../init.ftl">

<#assign layoutLocalService = serviceLocator.findService("com.liferay.portal.service.LayoutLocalService")>

<#function getLayoutJSON layout="">
	<#return escapeAttribute("{ \"layoutId\": ${layout.getLayoutId()}, \"groupId\": ${layout.getGroupId()}, \"privateLayout\": ${layout.isPrivateLayout()?string} }")>
</#function>

<#macro getLayoutsOptions
	groupId
	parentLayoutId
	privateLayout
	selectedPlid
	level = 0
>
	<#assign layoutService = serviceLocator.findService("com.liferay.portal.service.LayoutService")>

	<#assign layouts = layoutService.getLayouts(groupId, privateLayout, parentLayoutId)>

	<#if (layouts?size > 0)>
		<#if (level == 0)>
			<optgroup label="<#if (privateLayout)>${languageUtil.get(requestedLocale, "private-pages")}<#else>${languageUtil.get(requestedLocale, "public-pages")}</#if>">
		</#if>

		<#list layouts as curLayout>
			<#assign curLayoutJSON = getLayoutJSON(curLayout)>

			<#assign selected = false>

			<#if selectedLayout??>
				<#assign selected = (selectedPlid == curLayout.getPlid())>
			</#if>

			<@aui.option selected=selected value=curLayoutJSON>
				<#list 0..level as i>
					&ndash;&nbsp;
				</#list>

				${escape(curLayout.getName(requestedLocale))}
			</@>

			<@getLayoutsOptions
				groupId = scopeGroupId
				level = level + 1
				parentLayoutId = curLayout.getLayoutId()
				privateLayout = privateLayout
				selectedPlid = selectedPlid
			/>
		</#list>

		<#if (level == 0)>
			</optgroup>
		</#if>

	</#if>

</#macro>

<@aui["field-wrapper"] data=data helpMessage=escape(fieldStructure.tip) label=escape(label) required=required>
	<#assign selectedPlid = 0>

	<#if (fieldRawValue?? && fieldRawValue != "")>
		<#assign fieldLayoutJSONObject = jsonFactoryUtil.createJSONObject(fieldRawValue)>

		<#if (fieldLayoutJSONObject.getLong("groupId") > 0)>
			<#assign selectedLayoutGroupId = fieldLayoutJSONObject.getLong("groupId")>
		<#else>
			<#assign selectedLayoutGroupId = scopeGroupId>
		</#if>

		<#assign selectedLayout = layoutLocalService.fetchLayout(selectedLayoutGroupId, fieldLayoutJSONObject.getBoolean("privateLayout"), fieldLayoutJSONObject.getLong("layoutId"))!"">

		<#if (validator.isNotNull(selectedLayout))>
			<#assign selectedPlid = selectedLayout.getPlid()>
		</#if>
	</#if>

	<select name="${namespacedFieldName}">
		<#if (validator.isNotNull(selectedLayout) && !layoutPermission.contains(permissionChecker, selectedLayout, "VIEW"))>
			<optgroup label="${languageUtil.get(requestedLocale, "current")}">

				<#assign selectedLayoutJSON = getLayoutJSON(selectedLayout)>

				<@aui.option selected=true useModelValue=false value=selectedLayoutJSON>
					${escape(selectedLayout.getName(requestedLocale))}
				</@>

			</optgroup>
		</#if>

		<@getLayoutsOptions
			groupId = scopeGroupId
			parentLayoutId = 0
			privateLayout = false
			selectedPlid = selectedPlid
		/>

		<@getLayoutsOptions
			groupId = scopeGroupId
			parentLayoutId = 0
			privateLayout = true
			selectedPlid = selectedPlid
		/>
	</select>

	${fieldStructure.children}
</@>