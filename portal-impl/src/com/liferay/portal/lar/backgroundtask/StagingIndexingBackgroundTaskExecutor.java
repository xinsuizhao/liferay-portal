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

package com.liferay.portal.lar.backgroundtask;

import com.liferay.portal.kernel.backgroundtask.BackgroundTaskResult;
import com.liferay.portal.kernel.backgroundtask.BaseBackgroundTaskExecutor;
import com.liferay.portal.kernel.lar.PortletDataContext;
import com.liferay.portal.kernel.lar.PortletDataHandlerKeys;
import com.liferay.portal.kernel.log.Log;
import com.liferay.portal.kernel.log.LogFactoryUtil;
import com.liferay.portal.kernel.search.Indexer;
import com.liferay.portal.kernel.search.IndexerRegistryUtil;
import com.liferay.portal.kernel.util.MapUtil;
import com.liferay.portal.kernel.util.StringBundler;
import com.liferay.portal.kernel.util.StringPool;
import com.liferay.portal.model.BackgroundTask;
import com.liferay.portal.model.User;

import java.io.Serializable;

import java.util.Map;

/**
 * @author Mate Thurzo
 */
public class StagingIndexingBackgroundTaskExecutor
	extends BaseBackgroundTaskExecutor {

	public StagingIndexingBackgroundTaskExecutor() {
		setSerial(true);
	}

	@Override
	public BackgroundTaskResult execute(BackgroundTask backgroundTask)
		throws Exception {

		Map<String, Serializable> taskContextMap =
			backgroundTask.getTaskContextMap();

		PortletDataContext portletDataContext =
			(PortletDataContext)taskContextMap.get("portletDataContext");

		boolean importPermissions = MapUtil.getBoolean(
			portletDataContext.getParameterMap(),
			PortletDataHandlerKeys.PERMISSIONS);

		if (importPermissions) {
			long userId = MapUtil.getLong(taskContextMap, "userId");

			if (userId > 0) {
				Indexer indexer = IndexerRegistryUtil.nullSafeGetIndexer(
					User.class);

				indexer.reindex(userId);
			}
		}

		Indexer portletDataContextIndexer = IndexerRegistryUtil.getIndexer(
			PortletDataContext.class);

		portletDataContextIndexer.reindex(portletDataContext);

		return BackgroundTaskResult.SUCCESS;
	}

	@Override
	public String handleException(BackgroundTask backgroundTask, Exception e) {
		StringBundler sb = new StringBundler(4);

		sb.append("Indexing failed after importing with the following error: ");
		sb.append(e.getMessage());
		sb.append(StringPool.PERIOD);
		sb.append(StringPool.SPACE);
		sb.append("Please reindex site manually.");

		String message = sb.toString();

		if (_log.isInfoEnabled()) {
			_log.info(message);
		}

		return message;
	}

	private static Log _log = LogFactoryUtil.getLog(
		StagingIndexingBackgroundTaskExecutor.class);

}