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

package com.liferay.portal.kernel.search.util;

import com.liferay.portal.kernel.util.ArrayUtil;
import com.liferay.portal.kernel.util.HtmlUtil;
import com.liferay.portal.kernel.util.StringBundler;
import com.liferay.portal.kernel.util.StringPool;
import com.liferay.portal.kernel.util.StringUtil;
import com.liferay.portal.kernel.util.Validator;

import java.util.StringTokenizer;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 * @author Brian Wing Shun Chan
 * @author Shuyang Zhou
 * @author Tibor Lipusz
 */
public class SearchUtil {

	public static String highlight(String s, String[] queryTerms) {
		return highlight(s, queryTerms, _HIGHLIGHTS[0], _HIGHLIGHTS[1]);
	}

	public static String highlight(
		String s, String[] queryTerms, String highlight1, String highlight2) {

		if (Validator.isNull(s) || ArrayUtil.isEmpty(queryTerms)) {
			return s;
		}

		if (queryTerms.length == 0) {
			return StringPool.BLANK;
		}

		StringBundler sb = new StringBundler(2 * queryTerms.length - 1);

		for (int i = 0; i < queryTerms.length; i++) {
			sb.append(Pattern.quote(queryTerms[i].trim()));

			if ((i + 1) < queryTerms.length) {
				sb.append(StringPool.PIPE);
			}
		}

		int flags = Pattern.CASE_INSENSITIVE | Pattern.UNICODE_CASE;

		Pattern pattern = Pattern.compile(sb.toString(), flags);

		s = _highlight(
			HtmlUtil.unescape(s), pattern, _ESCAPE_SAFE_HIGHLIGHTS[0],
			_ESCAPE_SAFE_HIGHLIGHTS[1]);

		return StringUtil.replace(
			HtmlUtil.escape(s), _ESCAPE_SAFE_HIGHLIGHTS, _HIGHLIGHTS);
	}

	private static String _highlight(
		String s, Pattern pattern, String highlight1, String highlight2) {

		StringTokenizer st = new StringTokenizer(s);

		if (st.countTokens() == 0) {
			return StringPool.BLANK;
		}

		StringBundler sb = new StringBundler(2 * st.countTokens() - 1);

		while (st.hasMoreTokens()) {
			String token = st.nextToken();

			Matcher matcher = pattern.matcher(token);

			if (matcher.find()) {
				StringBuffer hightlighted = new StringBuffer();

				do {
					matcher.appendReplacement(
						hightlighted, highlight1 + matcher.group() +
						highlight2);
				}
				while (matcher.find());

				matcher.appendTail(hightlighted);

				sb.append(hightlighted);
			}
			else {
				sb.append(token);
			}

			if (st.hasMoreTokens()) {
				sb.append(StringPool.SPACE);
			}
		}

		return sb.toString();
	}

	private static final String[] _ESCAPE_SAFE_HIGHLIGHTS = {
		"[@HIGHLIGHT1@]", "[@HIGHLIGHT2@]"};

	private static final String[] _HIGHLIGHTS = {
		"<span class=\"highlight\">", "</span>"};

}