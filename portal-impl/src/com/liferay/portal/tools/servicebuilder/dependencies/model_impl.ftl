<#setting number_format = "0">

<#assign parentPKColumn = "">

<#if entity.isHierarchicalTree()>
	<#assign pkColumn = entity.getPKList()?first>

	<#assign parentPKColumn = entity.getColumn("parent" + pkColumn.methodName)>
</#if>

package ${packagePath}.model.impl;

<#if entity.hasCompoundPK()>
	import ${packagePath}.service.persistence.${entity.name}PK;
</#if>

import ${packagePath}.model.${entity.name};
import ${packagePath}.model.${entity.name}Model;
import ${packagePath}.model.${entity.name}Soap;

<#list entity.blobList as column>
	<#if column.lazy>
		import ${packagePath}.model.${entity.name}${column.methodName}BlobModel;
	</#if>
</#list>

import ${packagePath}.service.${entity.name}LocalServiceUtil;

import com.liferay.portal.LocaleException;
import com.liferay.portal.NoSuchModelException;
import com.liferay.portal.kernel.bean.AutoEscapeBeanHandler;
import com.liferay.portal.kernel.exception.PortalException;
import com.liferay.portal.kernel.exception.SystemException;
import com.liferay.portal.kernel.json.JSON;
import com.liferay.portal.kernel.language.LanguageUtil;
import com.liferay.portal.kernel.lar.StagedModelType;
import com.liferay.portal.kernel.trash.TrashHandler;
import com.liferay.portal.kernel.trash.TrashHandlerRegistryUtil;
import com.liferay.portal.kernel.util.DateUtil;
import com.liferay.portal.kernel.util.GetterUtil;
import com.liferay.portal.kernel.util.LocaleUtil;
import com.liferay.portal.kernel.util.LocalizationUtil;
import com.liferay.portal.kernel.util.ProxyUtil;
import com.liferay.portal.kernel.util.StringBundler;
import com.liferay.portal.kernel.util.StringPool;
import com.liferay.portal.kernel.util.Validator;
import com.liferay.portal.kernel.workflow.WorkflowConstants;
import com.liferay.portal.model.CacheModel;
import com.liferay.portal.model.ContainerModel;
import com.liferay.portal.model.TrashedModel;
import com.liferay.portal.model.impl.BaseModelImpl;
import com.liferay.portal.service.ServiceContext;
import com.liferay.portal.util.PortalUtil;
import com.liferay.portlet.expando.model.ExpandoBridge;
import com.liferay.portlet.expando.util.ExpandoBridgeFactoryUtil;
import com.liferay.portlet.trash.model.TrashEntry;
import com.liferay.portlet.trash.service.TrashEntryLocalServiceUtil;

import java.io.Serializable;

import java.sql.Blob;
import java.sql.Types;

import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.Set;
import java.util.TreeSet;

/**
 * The base model implementation for the ${entity.name} service. Represents a row in the &quot;${entity.table}&quot; database table, with each column mapped to a property of this class.
 *
 * <p>
 * This implementation and its corresponding interface {@link ${packagePath}.model.${entity.name}Model} exist only as a container for the default property accessors generated by ServiceBuilder. Helper methods and all application logic should be put in {@link ${entity.name}Impl}.
 * </p>
 *
 * @author ${author}
 * @see ${entity.name}Impl
 * @see ${packagePath}.model.${entity.name}
 * @see ${packagePath}.model.${entity.name}Model
 * @generated
 */

<#if entity.jsonEnabled>
	@JSON(strict = true)
</#if>

public class ${entity.name}ModelImpl extends BaseModelImpl<${entity.name}> implements ${entity.name}Model {

	/*
	 * NOTE FOR DEVELOPERS:
	 *
	 * Never modify or reference this class directly. All methods that expect a ${entity.humanName} model instance should use the {@link ${packagePath}.model.${entity.name}} interface instead.
	 */

	public static final String TABLE_NAME = "${entity.table}";

	<#compress>
		public static final Object[][] TABLE_COLUMNS = {
			<#list entity.getRegularColList() as column>
				<#assign sqlType = serviceBuilder.getSqlType(packagePath + ".model." + entity.getName(), column.getName(), column.getType())>

				{"${column.DBName}", Types.${sqlType}}

				<#if column_has_next>
					,
				</#if>
			</#list>
		};
	</#compress>

	public static final String TABLE_SQL_CREATE = "${serviceBuilder.getCreateTableSQL(entity)}";

	public static final String TABLE_SQL_DROP = "drop table ${entity.table}";

	<#if entity.getOrder()??>
		<#assign orderList = entity.getOrder().getColumns()>
	<#else>
		<#assign orderList = entity.getPKList()>
	</#if>

	<#assign orderByJPQL = "">

	<#list orderList as order>
		<#if entity.hasCompoundPK() && order.isPrimary()>
			<#assign orderByJPQL = orderByJPQL + entity.alias + ".id." + order.name>
		<#else>
			<#assign orderByJPQL = orderByJPQL + entity.alias + "." + order.name>
		</#if>

		<#if order.isOrderByAscending()>
			<#assign orderByJPQL = orderByJPQL + " ASC">
		<#else>
			<#assign orderByJPQL = orderByJPQL + " DESC">
		</#if>

		<#if order_has_next>
			<#assign orderByJPQL = orderByJPQL + ", ">
		</#if>
	</#list>

	public static final String ORDER_BY_JPQL = " ORDER BY ${orderByJPQL}";

	<#assign orderBySQL = "">

	<#list orderList as order>
		<#assign orderBySQL = orderBySQL + entity.table + "." + order.DBName>

		<#if order.isOrderByAscending()>
			<#assign orderBySQL = orderBySQL + " ASC">
		<#else>
			<#assign orderBySQL = orderBySQL + " DESC">
		</#if>

		<#if order_has_next>
			<#assign orderBySQL = orderBySQL + ", ">
		</#if>
	</#list>

	public static final String ORDER_BY_SQL = " ORDER BY ${orderBySQL}";

	public static final String DATA_SOURCE = "${entity.dataSource}";

	public static final String SESSION_FACTORY = "${entity.sessionFactory}";

	public static final String TX_MANAGER = "${entity.getTXManager()}";

	<#if entity.hasEagerBlobColumn()>
		public static final boolean ENTITY_CACHE_ENABLED = false;

		public static final boolean FINDER_CACHE_ENABLED = false;
	<#else>
		public static final boolean ENTITY_CACHE_ENABLED = GetterUtil.getBoolean(${propsUtil}.get("value.object.entity.cache.enabled.${packagePath}.model.${entity.name}"),

		<#if entity.isCacheEnabled()>
			true
		<#else>
			false
		</#if>

		);

		public static final boolean FINDER_CACHE_ENABLED = GetterUtil.getBoolean(${propsUtil}.get("value.object.finder.cache.enabled.${packagePath}.model.${entity.name}"),

		<#if entity.isCacheEnabled()>
			true
		<#else>
			false
		</#if>

		);

		<#assign columnBitmaskEnabled = true>

		<#if entity.finderColumnsList?size == 0>
			public static final boolean COLUMN_BITMASK_ENABLED = false;

			<#assign columnBitmaskEnabled = false>
		</#if>

		<#if entity.finderColumnsList?size &gt; 64>
			public static final boolean COLUMN_BITMASK_ENABLED = false;

			<#assign columnBitmaskEnabled = false >
		</#if>

		<#if columnBitmaskEnabled>
			public static final boolean COLUMN_BITMASK_ENABLED = GetterUtil.getBoolean(${propsUtil}.get("value.object.column.bitmask.enabled.${packagePath}.model.${entity.name}"), true);

			<#assign columnBitmask = 1>

			<#list entity.finderColumnsList as column>
				public static long ${column.name?upper_case}_COLUMN_BITMASK = ${columnBitmask}L;

				<#assign columnBitmask = columnBitmask * 2>
			</#list>

			<#list orderList as order>
				<#if !entity.finderColumnsList?seq_contains(order)>
					public static long ${order.name?upper_case}_COLUMN_BITMASK = ${columnBitmask}L;

					<#assign columnBitmask = columnBitmask * 2>
				</#if>
			</#list>
		</#if>
	</#if>

	<#if entity.hasRemoteService()>
		/**
		 * Converts the soap model instance into a normal model instance.
		 *
		 * @param soapModel the soap model instance to convert
		 * @return the normal model instance
		 */
		public static ${entity.name} toModel(${entity.name}Soap soapModel) {
			if (soapModel == null) {
				return null;
			}

			${entity.name} model = new ${entity.name}Impl();

			<#list entity.regularColList as column>
				model.set${column.methodName}(soapModel.get${column.methodName}());
			</#list>

			return model;
		}

		/**
		 * Converts the soap model instances into normal model instances.
		 *
		 * @param soapModels the soap model instances to convert
		 * @return the normal model instances
		 */
		public static List<${entity.name}> toModels(${entity.name}Soap[] soapModels) {
			if (soapModels == null) {
				return null;
			}

			List<${entity.name}> models = new ArrayList<${entity.name}>(soapModels.length);

			for (${entity.name}Soap soapModel : soapModels) {
				models.add(toModel(soapModel));
			}

			return models;
		}
	</#if>

	<#list entity.columnList as column>
		<#if column.mappingTable??>
			<#assign entityShortName = stringUtil.shorten(entity.name, 9, "")>

			public static final String MAPPING_TABLE_${stringUtil.upperCase(column.mappingTable)}_NAME = "${column.mappingTable}";

			<#compress>
				public static final Object[][] MAPPING_TABLE_${stringUtil.upperCase(column.mappingTable)}_COLUMNS = {
					<#list serviceBuilder.getMappingEntities(column.mappingTable) as mapColumn>
						<#assign sqlType = serviceBuilder.getSqlType(mapColumn.getType())>

						{"${mapColumn.DBName}", Types.${sqlType}}

						<#if mapColumn_has_next>
							,
						</#if>
					</#list>
				};
			</#compress>

			public static final String MAPPING_TABLE_${stringUtil.upperCase(column.mappingTable)}_SQL_CREATE = "${serviceBuilder.getCreateMappingTableSQL(serviceBuilder.getEntityMapping(column.mappingTable))}";

			public static final boolean FINDER_CACHE_ENABLED_${stringUtil.upperCase(column.mappingTable)} = GetterUtil.getBoolean(${propsUtil}.get("value.object.finder.cache.enabled.${column.mappingTable}"), true);
		</#if>
	</#list>

	public static final long LOCK_EXPIRATION_TIME = GetterUtil.getLong(${propsUtil}.get("lock.expiration.time.${packagePath}.model.${entity.name}"));

	public ${entity.name}ModelImpl() {
	}

	@Override
	public ${entity.PKClassName} getPrimaryKey() {
		<#if entity.hasCompoundPK()>
			return new ${entity.PKClassName}(

			<#list entity.PKList as column>
				_${column.name}

				<#if column_has_next>
					,
				</#if>
			</#list>

			);
		<#else>
			return _${entity.PKList[0].name};
		</#if>
	}

	@Override
	public void setPrimaryKey(${entity.PKClassName} primaryKey) {
		<#if entity.hasCompoundPK()>
			<#list entity.PKList as column>
				set${column.methodName}(primaryKey.${column.name});
			</#list>
		<#else>
			set${entity.PKList[0].methodName}(primaryKey);
		</#if>
	}

	@Override
	public Serializable getPrimaryKeyObj() {
		<#if entity.hasCompoundPK()>
			return new ${entity.PKClassName}(

			<#list entity.PKList as column>
				_${column.name}

				<#if column_has_next>
					,
				</#if>
			</#list>

			);
		<#else>
			return _${entity.PKList[0].name};
		</#if>
	}

	@Override
	public void setPrimaryKeyObj(Serializable primaryKeyObj) {
		setPrimaryKey(

		<#if entity.hasPrimitivePK()>
			((${serviceBuilder.getPrimitiveObj("${entity.PKClassName}")})
		<#else>
			(${entity.PKClassName})
		</#if>

		primaryKeyObj

		<#if entity.hasPrimitivePK()>
			)${serviceBuilder.getPrimitiveObjValue(serviceBuilder.getPrimitiveObj("${entity.PKClassName}"))}
		</#if>

		);
	}

	@Override
	public Class<?> getModelClass() {
		return ${entity.name}.class;
	}

	@Override
	public String getModelClassName() {
		return ${entity.name}.class.getName();
	}

	@Override
	public Map<String, Object> getModelAttributes() {
		Map<String, Object> attributes = new HashMap<String, Object>();

		<#list entity.regularColList as column>
			attributes.put("${column.name}", get${column.methodName}());
		</#list>

		return attributes;
	}

	@Override
	public void setModelAttributes(Map<String, Object> attributes) {
		<#list entity.regularColList as column>
			<#if column.isPrimitiveType()>
				${serviceBuilder.getPrimitiveObj(column.type)}
			<#else>
				${column.type}
			</#if>

			${column.name} =

			<#if column.isPrimitiveType()>
				(${serviceBuilder.getPrimitiveObj(column.type)})
			<#else>
				(${column.type})
			</#if>

			attributes.get("${column.name}");

			if (${column.name} != null) {
				set${column.methodName}(${column.name});
			}
		</#list>
	}

	<#list entity.regularColList as column>
		<#if column.name == "classNameId">
			@Override
			public String getClassName() {
				if (getClassNameId() <= 0) {
					return StringPool.BLANK;
				}

				return PortalUtil.getClassName(getClassNameId());
			}

			@Override
			public void setClassName(String className) {
				long classNameId = 0;

				if (Validator.isNotNull(className)) {
					classNameId = PortalUtil.getClassNameId(className);
				}

				setClassNameId(classNameId);
			}
		</#if>

		<#if column.jsonEnabled>
			@JSON
		<#elseif entity.jsonEnabled>
			@JSON(include = false)
		</#if>

		@Override
		public ${column.type} get${column.methodName}() {
			<#if column.type == "String" && column.isConvertNull()>
				if (_${column.name} == null) {
					return StringPool.BLANK;
				}
				else {
					return _${column.name};
				}
			<#else>
				<#if (column.type == "Blob") && column.lazy>
					if (_${column.name}BlobModel == null) {
						try {
							_${column.name}BlobModel = ${entity.name}LocalServiceUtil.get${column.methodName}BlobModel(getPrimaryKey());
						}
						catch (Exception e) {
						}
					}

					Blob blob = null;

					if (_${column.name}BlobModel != null) {
						blob = _${column.name}BlobModel.get${column.methodName}Blob();
					}

					return blob;
				<#else>
					return _${column.name};
				</#if>
			</#if>
		}

		<#if column.localized>
			@Override
			public String get${column.methodName}(Locale locale) {
				String languageId = LocaleUtil.toLanguageId(locale);

				return get${column.methodName}(languageId);
			}

			@Override
			public String get${column.methodName}(Locale locale, boolean useDefault) {
				String languageId = LocaleUtil.toLanguageId(locale);

				return get${column.methodName}(languageId, useDefault);
			}

			@Override
			public String get${column.methodName}(String languageId) {
				return LocalizationUtil.getLocalization(get${column.methodName}(), languageId);
			}

			@Override
			public String get${column.methodName}(String languageId, boolean useDefault) {
				return LocalizationUtil.getLocalization(get${column.methodName}(), languageId, useDefault);
			}

			@Override
			public String get${column.methodName}CurrentLanguageId() {
				return _${column.name}CurrentLanguageId;
			}

			@JSON
			@Override
			public String get${column.methodName}CurrentValue() {
				Locale locale = getLocale(_${column.name}CurrentLanguageId);

				return get${column.methodName}(locale);
			}

			@Override
			public Map<Locale, String> get${column.methodName}Map() {
				return LocalizationUtil.getLocalizationMap(get${column.methodName}());
			}
		</#if>

		<#if column.type== "boolean">
			@Override
			public ${column.type} is${column.methodName}() {
				return _${column.name};
			}
		</#if>

		@Override
		public void set${column.methodName}(${column.type} ${column.name}) {
			<#if column.name == "uuid">
				<#if column.isFinderPath()>
					if (_originalUuid == null) {
						_originalUuid = _uuid;
					}
				</#if>

				_uuid = uuid;
			<#else>
				<#if column.isOrderColumn() && columnBitmaskEnabled>
					_columnBitmask = -1L;
				</#if>

				<#if column.isFinderPath() || ((parentPKColumn != "") && (parentPKColumn.name == column.name))>
					<#if !column.isOrderColumn() && columnBitmaskEnabled>
						_columnBitmask |= ${column.name?upper_case}_COLUMN_BITMASK;
					</#if>

					<#if column.isPrimitiveType()>
						if (!_setOriginal${column.methodName}) {
							_setOriginal${column.methodName} = true;
					<#else>
						if (_original${column.methodName} == null) {
					</#if>

						_original${column.methodName} = _${column.name};
					}
				</#if>

				<#if (column.type == "Blob") && column.lazy>
					if (_${column.name}BlobModel == null) {
						_${column.name}BlobModel = new ${entity.name}${column.methodName}BlobModel(getPrimaryKey(), ${column.name});
					}
					else {
						_${column.name}BlobModel.set${column.methodName}Blob(${column.name});
					}
				<#else>
					_${column.name} = ${column.name};
				</#if>
			</#if>
		}

		<#if column.localized>
			@Override
			public void set${column.methodName}(String ${column.name}, Locale locale) {
				<#if entity.isGroupedModel()>
					set${column.methodName}(${column.name}, locale, LocaleUtil.getSiteDefault());
				<#else>
					set${column.methodName}(${column.name}, locale, LocaleUtil.getDefault());
				</#if>
			}

			@Override
			public void set${column.methodName}(String ${column.name}, Locale locale, Locale defaultLocale) {
				String languageId = LocaleUtil.toLanguageId(locale);
				String defaultLanguageId = LocaleUtil.toLanguageId(defaultLocale);

				if (Validator.isNotNull(${column.name})) {
					set${column.methodName}(LocalizationUtil.updateLocalization(get${column.methodName}(), "${column.methodName}", ${column.name}, languageId, defaultLanguageId));
				}
				else {
					set${column.methodName}(LocalizationUtil.removeLocalization(get${column.methodName}(), "${column.methodName}", languageId));
				}
			}

			@Override
			public void set${column.methodName}CurrentLanguageId(String languageId) {
				_${column.name}CurrentLanguageId = languageId;
			}

			@Override
			public void set${column.methodName}Map(Map<Locale, String> ${column.name}Map) {
				<#if entity.isGroupedModel()>
					set${column.methodName}Map(${column.name}Map, LocaleUtil.getSiteDefault());
				<#else>
					set${column.methodName}Map(${column.name}Map, LocaleUtil.getDefault());
				</#if>
			}

			@Override
			public void set${column.methodName}Map(Map<Locale, String> ${column.name}Map, Locale defaultLocale) {
				if (${column.name}Map == null) {
					return;
				}

				set${column.methodName}(LocalizationUtil.updateLocalization(${column.name}Map, get${column.methodName}(), "${column.methodName}", LocaleUtil.toLanguageId(defaultLocale)));
			}
		</#if>

		<#if (column.name == "resourcePrimKey") && entity.isResourcedModel()>
			@Override
			public boolean isResourceMain() {
				return true;
			}
		</#if>

		<#if column.userUuid>
			@Override
			public String get${column.methodUserUuidName}() throws SystemException {
				return PortalUtil.getUserValue(get${column.methodName}(), "uuid", _${column.userUuidName});
			}

			@Override
			public void set${column.methodUserUuidName}(String ${column.userUuidName}) {
				_${column.userUuidName} = ${column.userUuidName};
			}
		</#if>

		<#if column.isFinderPath() || ((parentPKColumn != "") && (parentPKColumn.name == column.name))>
			public ${column.type} getOriginal${column.methodName}() {
				<#if column.type == "String" && column.isConvertNull()>
					return GetterUtil.getString(_original${column.methodName});
				<#else>
					return _original${column.methodName};
				</#if>
			}
		</#if>
	</#list>

	<#list cacheFields as cacheField>
		<#assign variableName = serviceBuilder.getVariableName(cacheField)>
		<#assign methodName = textFormatter.format(variableName, 6)>
		<#assign typeName = cacheField.getType().getGenericValue()>

		public ${typeName} get${methodName}() {
			<#if cacheField.getType().isPrimitive()>
				<#if typeName == "boolean">
					return false;
				<#else>
					return 0;
				</#if>
			<#else>
				return null;
			</#if>
		}

		public void set${methodName}(${typeName} ${variableName}) {
		}
	</#list>

	<#if entity.isContainerModel()>
		<#assign hasParentContainerModelId = entity.hasColumn("parentContainerModelId")>

		<#list entity.columnList as column>
			<#if column.isContainerModel() && (column.name != "containerModelId")>
				@Override
				public long getContainerModelId() {
					return get${column.methodName}();
				}

				@Override
				public void setContainerModelId(long containerModelId) {
					_${column.name} = containerModelId;
				}
			</#if>

			<#if column.isParentContainerModel() && (column.name != "parentContainerModelId")>
				<#assign hasParentContainerModelId = true>

				@Override
				public long getParentContainerModelId() {
					return get${column.methodName}();
				}

				@Override
				public void setParentContainerModelId(long parentContainerModelId) {
					_${column.name} = parentContainerModelId;
				}
			</#if>
		</#list>

		@Override
		public String getContainerModelName() {
			<#if entity.hasColumn("name")>
				return String.valueOf(getName());
			<#else>
				return String.valueOf(getContainerModelId());
			</#if>
		}

		<#if !hasParentContainerModelId>
			@Override
			public long getParentContainerModelId() {
				return 0;
			}

			@Override
			public void setParentContainerModelId(long parentContainerModelId) {
			}
		</#if>
	</#if>

	<#if entity.isStagedModel()>
		@Override
		public StagedModelType getStagedModelType() {
			<#if entity.isTypedModel()>
				return new StagedModelType(PortalUtil.getClassNameId(${entity.name}.class.getName()), getClassNameId());
			<#else>
				return new StagedModelType(PortalUtil.getClassNameId(${entity.name}.class.getName()));
			</#if>
		}
	</#if>

	<#if entity.isTrashEnabled()>
		<#if !entity.isWorkflowEnabled()>
			@Override
			public int getStatus() {
				return 0;
			}
		</#if>

		@Override
		public TrashEntry getTrashEntry() throws PortalException, SystemException {
			if (!isInTrash()) {
				return null;
			}

			TrashEntry trashEntry = TrashEntryLocalServiceUtil.fetchEntry(getModelClassName(), getTrashEntryClassPK());

			if (trashEntry != null) {
				return trashEntry;
			}

			TrashHandler trashHandler = getTrashHandler();

			if (!Validator.isNull(trashHandler.getContainerModelClassName())) {
				ContainerModel containerModel = null;

				try {
					containerModel = trashHandler.getParentContainerModel(this);
				}
				catch (NoSuchModelException nsme) {
					return null;
				}

				while (containerModel != null) {
					if (containerModel instanceof TrashedModel) {
						TrashedModel trashedModel = (TrashedModel)containerModel;

						return trashedModel.getTrashEntry();
					}

					trashHandler = TrashHandlerRegistryUtil.getTrashHandler(trashHandler.getContainerModelClassName());

					if (trashHandler == null) {
						return null;
					}

					containerModel = trashHandler.getContainerModel(containerModel.getParentContainerModelId());
				}
			}

			return null;
		}

		@Override
		public long getTrashEntryClassPK() {
			return getPrimaryKey();
		}

		@Override
		public TrashHandler getTrashHandler() {
			return TrashHandlerRegistryUtil.getTrashHandler(getModelClassName());
		}

		@Override
		public boolean isInTrash() {
			if (getStatus() == WorkflowConstants.STATUS_IN_TRASH) {
				return true;
			}
			else {
				return false;
			}
		}

		@Override
		public boolean isInTrashContainer() {
			TrashHandler trashHandler = getTrashHandler();

			if ((trashHandler == null) || Validator.isNull(trashHandler.getContainerModelClassName())) {
				return false;
			}

			try {
				ContainerModel containerModel = trashHandler.getParentContainerModel(this);

				if (containerModel == null) {
					return false;
				}

				if (containerModel instanceof TrashedModel) {
					return ((TrashedModel)containerModel).isInTrash();
				}
			}
			catch (Exception e) {
			}

			return false;
		}
	</#if>

	<#if entity.isWorkflowEnabled()>
		/**
		 * @deprecated As of 6.1.0, replaced by {@link #isApproved}
		 */
		@Override
		public boolean getApproved() {
			return isApproved();
		}

		@Override
		public boolean isApproved() {
			if (getStatus() == WorkflowConstants.STATUS_APPROVED) {
				return true;
			}
			else {
				return false;
			}
		}

		@Override
		public boolean isDenied() {
			if (getStatus() == WorkflowConstants.STATUS_DENIED) {
				return true;
			}
			else {
				return false;
			}
		}

		@Override
		public boolean isDraft() {
			if (getStatus() == WorkflowConstants.STATUS_DRAFT) {
				return true;
			}
			else {
				return false;
			}
		}

		@Override
		public boolean isExpired() {
			if (getStatus() == WorkflowConstants.STATUS_EXPIRED) {
				return true;
			}
			else {
				return false;
			}
		}

		@Override
		public boolean isInactive() {
			if (getStatus() == WorkflowConstants.STATUS_INACTIVE) {
				return true;
			}
			else {
				return false;
			}
		}

		@Override
		public boolean isIncomplete() {
			if (getStatus() == WorkflowConstants.STATUS_INCOMPLETE) {
				return true;
			}
			else {
				return false;
			}
		}

		@Override
		public boolean isPending() {
			if (getStatus() == WorkflowConstants.STATUS_PENDING) {
				return true;
			}
			else {
				return false;
			}
		}

		@Override
		public boolean isScheduled() {
			if (getStatus() == WorkflowConstants.STATUS_SCHEDULED) {
				return true;
			}
			else {
				return false;
			}
		}
	</#if>

	<#if columnBitmaskEnabled>
		public long getColumnBitmask() {
			return _columnBitmask;
		}
	</#if>

	<#if (entity.PKClassName == "long") && !stringUtil.startsWith(entity.name, "Expando")>
		@Override
		public ExpandoBridge getExpandoBridge() {
			return ExpandoBridgeFactoryUtil.getExpandoBridge(

				<#if entity.hasColumn("companyId")>
					getCompanyId(),
				<#else>
					0,
				</#if>

				${entity.name}.class.getName(), getPrimaryKey());
		}

		@Override
		public void setExpandoBridgeAttributes(ServiceContext serviceContext) {
			ExpandoBridge expandoBridge = getExpandoBridge();

			expandoBridge.setAttributes(serviceContext);
		}
	</#if>

	<#if entity.hasLocalizedColumn()>
		@Override
		public String[] getAvailableLanguageIds() {
			Set<String> availableLanguageIds = new TreeSet<String>();

			<#list entity.regularColList as column>
				<#if column.localized>
					Map<Locale, String> ${column.name}Map = get${column.methodName}Map();

					for (Map.Entry<Locale, String> entry : ${column.name}Map.entrySet()) {
						Locale locale = entry.getKey();
						String value = entry.getValue();

						if (Validator.isNotNull(value)) {
							availableLanguageIds.add(LocaleUtil.toLanguageId(locale));
						}
					}
				</#if>
			</#list>

			return availableLanguageIds.toArray(new String[availableLanguageIds.size()]);
		}

		@Override
		public String getDefaultLanguageId() {
			<#list entity.regularColList as column>
				<#if column.localized>
					String xml = get${column.methodName}();

					if (xml == null) {
						return StringPool.BLANK;
					}

					return LocalizationUtil.getDefaultLanguageId(xml);
					<#break>
				</#if>
			</#list>
		}

		@Override
		public void prepareLocalizedFieldsForImport() throws LocaleException {
			prepareLocalizedFieldsForImport (null);
		}

		@Override
		@SuppressWarnings("unused")
		public void prepareLocalizedFieldsForImport(Locale defaultImportLocale) throws LocaleException {
			Locale defaultLocale = LocaleUtil.getDefault();

			String modelDefaultLanguageId = getDefaultLanguageId();

			<#list entity.regularColList as column>
				<#if column.localized>
					String ${column.name} = get${column.methodName}(defaultLocale);

					if (Validator.isNull(${column.name})) {
						set${column.methodName}(get${column.methodName}(modelDefaultLanguageId), defaultLocale);
					}
					else {
					  set${column.methodName}(get${column.methodName}(defaultLocale), defaultLocale, defaultLocale);
					}
				</#if>
			</#list>
		}
	</#if>

	@Override
	public ${entity.name} toEscapedModel() {
		if (_escapedModel == null) {
			_escapedModel = (${entity.name})ProxyUtil.newProxyInstance(_classLoader, _escapedModelInterfaces, new AutoEscapeBeanHandler(this));
		}

		return _escapedModel;
	}

	@Override
	public Object clone() {
		${entity.name}Impl ${entity.varName}Impl = new ${entity.name}Impl();

		<#list entity.regularColList as column>
			<#if column.type != "Blob">
				${entity.varName}Impl.set${column.methodName}(

				<#if column.EJBName??>
					(${column.EJBName})get${column.methodName}().clone()
				<#else>
					get${column.methodName}()
				</#if>

				);
			</#if>
		</#list>

		${entity.varName}Impl.resetOriginalValues();

		return ${entity.varName}Impl;
	}

	@Override
	public int compareTo(${entity.name} ${entity.varName}) {
		<#if entity.isOrdered()>
			int value = 0;

			<#list entity.order.columns as column>
				<#if column.isPrimitiveType()>
					<#if column.type == "boolean">
						<#assign ltComparator = "==">
						<#assign gtComparator = "!=">
					<#else>
						<#assign ltComparator = "<">
						<#assign gtComparator = ">">
					</#if>

					if (get${column.methodName}() ${ltComparator} ${entity.varName}.get${column.methodName}()) {
						value = -1;
					}
					else if (get${column.methodName}() ${gtComparator} ${entity.varName}.get${column.methodName}()) {
						value = 1;
					}
					else {
						value = 0;
					}
				<#else>
					<#if column.type == "Date">
						value = DateUtil.compareTo(get${column.methodName}(), ${entity.varName}.get${column.methodName}());
					<#else>
						<#if column.isCaseSensitive()>
							value = get${column.methodName}().compareTo(${entity.varName}.get${column.methodName}());
						<#else>
							value = get${column.methodName}().compareToIgnoreCase(${entity.varName}.get${column.methodName}());
						</#if>
					</#if>
				</#if>

				<#if !column.isOrderByAscending()>
					value = value * -1;
				</#if>

				if (value != 0) {
					return value;
				}
			</#list>

			return 0;
		<#else>
			${entity.PKClassName} primaryKey = ${entity.varName}.getPrimaryKey();

			<#if entity.hasPrimitivePK()>
				if (getPrimaryKey() < primaryKey) {
					return -1;
				}
				else if (getPrimaryKey() > primaryKey) {
					return 1;
				}
				else {
					return 0;
				}
			<#else>
				return getPrimaryKey().compareTo(primaryKey);
			</#if>
		</#if>
	}

	@Override
	public boolean equals(Object obj) {
		if (this == obj) {
			return true;
		}

		if (!(obj instanceof ${entity.name})) {
			return false;
		}

		${entity.name} ${entity.varName} = (${entity.name})obj;

		${entity.PKClassName} primaryKey = ${entity.varName}.getPrimaryKey();

		<#if entity.hasPrimitivePK()>
			if (getPrimaryKey() == primaryKey) {
		<#else>
			if (getPrimaryKey().equals(primaryKey)) {
		</#if>

			return true;
		}
		else{
			return false;
		}
	}

	@Override
	public int hashCode() {
		<#if entity.hasPrimitivePK(false)>
			<#if entity.PKClassName == "int">
				return getPrimaryKey();
			<#else>
				return (int)getPrimaryKey();
			</#if>
		<#else>
			return getPrimaryKey().hashCode();
		</#if>
	}

	@Override
	public void resetOriginalValues() {
		<#list entity.regularColList as column>
			<#if column.isFinderPath() || ((parentPKColumn != "") && (parentPKColumn.name == column.name)) || ((column.type == "Blob") && column.lazy)>
				<#if !cloneCastModelImpl??>
					<#assign cloneCastModelImpl = true>

					${entity.name}ModelImpl ${entity.varName}ModelImpl = this;
				</#if>
			</#if>

			<#if column.isFinderPath() || ((parentPKColumn != "") && (parentPKColumn.name == column.name))>
				${entity.varName}ModelImpl._original${column.methodName} = ${entity.varName}ModelImpl._${column.name};

				<#if column.isPrimitiveType()>
					${entity.varName}ModelImpl._setOriginal${column.methodName} = false;
				</#if>
			</#if>

			<#if (column.type == "Blob") && column.lazy>
				${entity.varName}ModelImpl._${column.name}BlobModel = null;
			</#if>
		</#list>

		<#list cacheFields as cacheField>
			<#assign variableName = serviceBuilder.getVariableName(cacheField)>
			<#assign methodName = textFormatter.format(variableName, 6)>

			set${methodName}(null);
		</#list>

		<#if columnBitmaskEnabled>
			${entity.varName}ModelImpl._columnBitmask = 0;
		</#if>
	}

	@Override
	public CacheModel<${entity.name}> toCacheModel() {
		${entity.name}CacheModel ${entity.varName}CacheModel = new ${entity.name}CacheModel();

		<#list entity.regularColList as column>
			<#if column.type != "Blob">
				<#if column.type == "Date">
					Date ${column.name} = get${column.methodName}();

					if (${column.name} != null) {
						${entity.varName}CacheModel.${column.name} = ${column.name}.getTime();
					}
					else {
						${entity.varName}CacheModel.${column.name} = Long.MIN_VALUE;
					}
				<#else>
					${entity.varName}CacheModel.${column.name} = get${column.methodName}();

					<#if column.type == "String">
						String ${column.name} = ${entity.varName}CacheModel.${column.name};

						if ((${column.name} != null) && (${column.name}.length() == 0)) {
							${entity.varName}CacheModel.${column.name} = null;
						}
					</#if>
				</#if>
			</#if>
		</#list>

		<#list cacheFields as cacheField>
			<#assign methodName = textFormatter.format(serviceBuilder.getVariableName(cacheField), 6)>

			${entity.varName}CacheModel.${cacheField.name} = get${methodName}();
		</#list>

		return ${entity.varName}CacheModel;
	}

	@Override
	public String toString() {
		StringBundler sb = new StringBundler(${entity.regularColList?size * 2 + 1});

		<#list entity.regularColList as column>
			<#if (column.type != "Blob") || !column.lazy>
				<#if column_index == 0>
					sb.append("{${column.name}=");
					sb.append(get${column.methodName}());
				<#elseif column_has_next>
					sb.append(", ${column.name}=");
					sb.append(get${column.methodName}());
				<#else>
					sb.append(", ${column.name}=");
					sb.append(get${column.methodName}());
					sb.append("}");
				</#if>
			</#if>
		</#list>

		return sb.toString();
	}

	@Override
	public String toXmlString() {
		StringBundler sb = new StringBundler(${entity.regularColList?size * 3 + 4});

		sb.append("<model><model-name>");
		sb.append("${packagePath}.model.${entity.name}");
		sb.append("</model-name>");

		<#list entity.regularColList as column>
			<#if (column.type != "Blob") || !column.lazy>
				sb.append("<column><column-name>${column.name}</column-name><column-value><![CDATA[");
				sb.append(get${column.methodName}());
				sb.append("]]></column-value></column>");
			</#if>
		</#list>

		sb.append("</model>");

		return sb.toString();
	}

	private static ClassLoader _classLoader = ${entity.name}.class.getClassLoader();

	private static Class<?>[] _escapedModelInterfaces = new Class[] {${entity.name}.class};

	<#list entity.regularColList as column>
		<#if (column.type == "Blob") && column.lazy>
			private ${entity.name}${column.methodName}BlobModel _${column.name}BlobModel;
		<#else>
			private ${column.type} _${column.name};

			<#if column.localized>
				private String _${column.name}CurrentLanguageId;
			</#if>

			<#if column.userUuid>
				private String _${column.userUuidName};
			</#if>

			<#if column.isFinderPath() || ((parentPKColumn != "") && (parentPKColumn.name == column.name))>
				private ${column.type} _original${column.methodName};

				<#if column.isPrimitiveType()>
					private boolean _setOriginal${column.methodName};
				</#if>
			</#if>
		</#if>
	</#list>

	<#if columnBitmaskEnabled>
		private long _columnBitmask;
	</#if>

	private ${entity.name} _escapedModel;

}