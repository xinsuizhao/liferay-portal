/**
 * Copyright (c) 2000-present Liferay, Inc. All rights reserved.
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

package com.liferay.portal.lar;

import com.liferay.portal.kernel.dao.orm.DynamicQuery;
import com.liferay.portal.kernel.dao.orm.Property;
import com.liferay.portal.kernel.dao.orm.PropertyFactoryUtil;
import com.liferay.portal.kernel.lar.PortletDataContext;
import com.liferay.portal.kernel.search.BaseIndexer;
import com.liferay.portal.kernel.search.Document;
import com.liferay.portal.kernel.search.Indexer;
import com.liferay.portal.kernel.search.IndexerRegistryUtil;
import com.liferay.portal.kernel.search.SearchContext;
import com.liferay.portal.kernel.search.Summary;
import com.liferay.portal.kernel.util.ArrayUtil;
import com.liferay.portal.kernel.util.GetterUtil;
import com.liferay.portal.kernel.util.ReflectionUtil;
import com.liferay.portlet.documentlibrary.model.DLFileEntry;
import com.liferay.portlet.documentlibrary.service.DLFileEntryLocalServiceUtil;
import com.liferay.portlet.dynamicdatamapping.model.DDMStructure;
import com.liferay.portlet.dynamicdatamapping.service.DDMStructureLocalServiceUtil;
import com.liferay.portlet.journal.model.JournalArticle;
import com.liferay.portlet.journal.service.JournalArticleLocalServiceUtil;

import java.lang.reflect.Method;

import java.util.ArrayList;
import java.util.List;
import java.util.Locale;
import java.util.Map;

import javax.portlet.PortletURL;

/**
 * @author Mate Thurzo
 */
public class PortletDataContextIndexer extends BaseIndexer {

	public static final String[] CLASS_NAMES =
		{PortletDataContext.class.getName()};

	public static final String PORTLET_ID = "PortletDataContextIndexer";

	@Override
	protected void doDelete(Object obj) throws Exception {
	}

	@Override
	protected Document doGetDocument(Object obj) throws Exception {
		return null;
	}

	@Override
	protected Summary doGetSummary(
			Document document, Locale locale, String snippet,
			PortletURL portletURL)
		throws Exception {

		return null;
	}

	@Override
	protected void doReindex(Object obj) throws Exception {
		PortletDataContext portletDataContext = (PortletDataContext)obj;

		_groupId = portletDataContext.getGroupId();
		_newPrimaryKeysMaps = portletDataContext.getNewPrimaryKeysMaps();

		for (Map.Entry<String, Map<?, ?>> newPrimaryKeysMapsEntry :
				_newPrimaryKeysMaps.entrySet()) {

			String className = newPrimaryKeysMapsEntry.getKey();

			Indexer indexer = IndexerRegistryUtil.getIndexer(className);

			if ((indexer == null) &&
				!className.equals(DDMStructure.class.getName())) {

				continue;
			}

			Map<?, ?> newPrimaryKeysMap = newPrimaryKeysMapsEntry.getValue();

			List<Long> newPrimaryKeys = new ArrayList<Long>();

			for (Object object : newPrimaryKeysMap.values()) {
				long classPK = GetterUtil.getLong(object);

				if (classPK > 0) {
					newPrimaryKeys.add(classPK);
				}
			}

			if (className.equals(DDMStructure.class.getName())) {
				reindexDDMStructures(newPrimaryKeys);
			}
			else {
				for (Long classPK : newPrimaryKeys) {
					indexer.reindex(className, classPK);
				}
			}
		}
	}

	@Override
	protected void doReindexDDMStructures(List<Long> ddmStructureIds)
		throws Exception {

		if ((ddmStructureIds == null) || ddmStructureIds.isEmpty()) {
			return;
		}

		String[] ddmStructureKeys = new String[ddmStructureIds.size()];

		for (int i = 0; i < ddmStructureIds.size(); i++) {
			long structureId = ddmStructureIds.get(i);

			DDMStructure ddmStructure =
				DDMStructureLocalServiceUtil.getDDMStructure(structureId);

			ddmStructureKeys[i] = ddmStructure.getStructureKey();
		}

		DynamicQuery journalArticleDynamicQuery =
			JournalArticleLocalServiceUtil.dynamicQuery();

		Property groupIdProperty = PropertyFactoryUtil.forName("groupId");

		journalArticleDynamicQuery.add(groupIdProperty.eq(_groupId));

		Property structureIdProperty = PropertyFactoryUtil.forName(
			"structureId");

		journalArticleDynamicQuery.add(
			structureIdProperty.in(ddmStructureKeys));

		List<JournalArticle> journalArticles =
			JournalArticleLocalServiceUtil.dynamicQuery(
				journalArticleDynamicQuery);

		Map<?, ?> journalArticlePrimaryKeysMap = _newPrimaryKeysMaps.get(
			JournalArticle.class.getName());

		Indexer journalArticleIndexer = IndexerRegistryUtil.getIndexer(
			JournalArticle.class);

		for (JournalArticle article : journalArticles) {
			if (containsValue(
					journalArticlePrimaryKeysMap,
					article.getResourcePrimKey())) {

				continue;
			}

			journalArticleIndexer.reindex(article);
		}

		List<DLFileEntry> dlFileEntries = new ArrayList<DLFileEntry>();

		try {
			Method method = ReflectionUtil.getDeclaredMethod(
				DLFileEntryLocalServiceUtil.class, "getDDMStructureFileEntries",
				long.class, long[].class);

			Object object = method.invoke(
				DLFileEntryLocalServiceUtil.class, _groupId,
				ArrayUtil.toLongArray(ddmStructureIds));

			if (object != null) {
				dlFileEntries = (List<DLFileEntry>)object;
			}
		}
		catch (Exception e) {
			List<DLFileEntry> allDlFileEntries =
				DLFileEntryLocalServiceUtil.getDDMStructureFileEntries(
					ArrayUtil.toLongArray(ddmStructureIds));

			for (DLFileEntry dlFileEntry : allDlFileEntries) {
				if (_groupId == dlFileEntry.getGroupId()) {
					dlFileEntries.add(dlFileEntry);
				}
			}
		}

		Map<?, ?> dlFileEntryPrimaryKeysMap = _newPrimaryKeysMaps.get(
			DLFileEntry.class.getName());

		Indexer dlFileEntryIndexer = IndexerRegistryUtil.getIndexer(
			DLFileEntry.class);

		for (DLFileEntry dlFileEntry : dlFileEntries) {
			if (containsValue(
					dlFileEntryPrimaryKeysMap, dlFileEntry.getFileEntryId())) {

				continue;
			}

			dlFileEntryIndexer.reindex(dlFileEntry);
		}
	}

	protected boolean containsValue(Map<?, ?> map, long value) {
		if ((map == null) || map.isEmpty() || (value <= 0)) {
			return false;
		}

		for (Object object : map.values()) {
			if (GetterUtil.getLong(object) == value) {
				return true;
			}
		}

		return false;
	}

	@Override
	protected void doReindex(String className, long classPK) throws Exception {
	}

	@Override
	protected void doReindex(String[] ids) throws Exception {
	}

	@Override
	protected String getPortletId(SearchContext searchContext) {
		return PORTLET_ID;
	}

	@Override
	public String[] getClassNames() {
		return CLASS_NAMES;
	}

	@Override
	public String getPortletId() {
		return PORTLET_ID;
	}

	private Map<String, Map<?, ?>> _newPrimaryKeysMaps;
	private long _groupId;

}