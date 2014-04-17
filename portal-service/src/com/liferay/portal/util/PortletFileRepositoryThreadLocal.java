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

package com.liferay.portal.util;

import com.liferay.portal.kernel.util.AutoResetThreadLocal;

/**
 * @author Michael C. Han
 */
public class PortletFileRepositoryThreadLocal {

	public static boolean checkFileSize() {
		if (isAddBackgroundTaskAttachmentInProcess() ||
			isAddTempFileInProcess()) {

			return false;
		}

		return true;
	}

	public static boolean isAddBackgroundTaskAttachmentInProcess() {
		return _addBackgroundTaskAttachmentInProcess.get();
	}

	public static boolean isAddTempFileInProcess() {
		return _addTempFileInProcess.get();
	}

	public static void setAddBackgroundTaskAttachmentInProcess(
		boolean addBackgroundTaskAttachmentInProcess) {

		_addBackgroundTaskAttachmentInProcess.set(
			addBackgroundTaskAttachmentInProcess);
	}

	public static void setAddTempFileInProcess(boolean addTempFileInProcess) {
		_addTempFileInProcess.set(addTempFileInProcess);
	}

	private static ThreadLocal<Boolean> _addBackgroundTaskAttachmentInProcess =
		new AutoResetThreadLocal<Boolean>(
			PortletFileRepositoryThreadLocal.class +
				"._addBackgroundTaskAttachmentInProcess", false);
	private static ThreadLocal<Boolean> _addTempFileInProcess =
		new AutoResetThreadLocal<Boolean>(
			PortletFileRepositoryThreadLocal.class +
				"._addTempFileInProcess", false);

}