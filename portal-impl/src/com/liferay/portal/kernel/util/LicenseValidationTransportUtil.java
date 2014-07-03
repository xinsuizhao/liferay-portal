/**
 * Copyright (c) 2000-2010 Liferay, Inc. All rights reserved.
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

package com.liferay.portal.kernel.util;

import java.lang.reflect.Field;
import com.liferay.util.transport.MulticastTransport;

public class LicenseValidationTransportUtil {
	public static void stopMulticastTransportThread() {
		try {
			Class licenseManagerClass =
				PortalClassLoaderUtil.getClassLoader().loadClass(
					"com.liferay.portal.license.LicenseManager");

			Field[] fields = licenseManagerClass.getDeclaredFields();

			for (Field field : fields) {
				if ("com.liferay.util.transport.MulticastTransport".equals(
					field.getType().getName())) {

					field.setAccessible(true);

					try {
						Object value = field.get(null);
						MulticastTransport multicastTransport =
							(MulticastTransport)value;

						if (multicastTransport != null) {
							multicastTransport.disconnect();
						}
					}
					catch (IllegalAccessException iae) {
						iae.printStackTrace();
					}
					finally {
						field.setAccessible(false);
					}
				}
			}
		}		catch (ClassNotFoundException e) {
			e.printStackTrace();
		}
	}
}
