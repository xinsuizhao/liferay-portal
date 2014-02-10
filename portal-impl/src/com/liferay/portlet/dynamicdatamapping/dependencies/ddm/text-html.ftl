<#include "../init.ftl">

<#assign skipEditorLoading = paramUtil.getBoolean(request, "p_p_isolated")>

<@aui["field-wrapper"] data=data helpMessage=escape(fieldStructure.tip) label=escape(label) required=required>
	<@liferay_ui["input-editor"] initMethod="${namespacedFieldName}InitEditor" name="${namespacedFieldName}Editor" skipEditorLoading=skipEditorLoading />

	<@aui.input name=namespacedFieldName type="hidden" value=fieldValue />

	${fieldStructure.children}
</@>

<@aui.script>
	window['${portletNamespace}${namespacedFieldName}InitEditor'] = function() {
		return "${unicodeFormatter.toString(fieldValue)}";
	}
</@>

<@aui.script use="aui-base">
	var field = A.one('#${portletNamespace}${namespacedFieldName}');

	if (field) {
		var form = field.get('form');

		if (form) {
			Liferay.on(
				'submitForm',
				function(event) {
					if (event.form.compareTo(form)) {
						field.val(window['${portletNamespace}${namespacedFieldName}Editor'].getHTML());
					}
				}
			);
		}
	}
</@>