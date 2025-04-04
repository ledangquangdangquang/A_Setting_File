// ==UserScript==
// @name         Ẩn Reels, Lối tắt, Story, "Bạn đang nghĩ gì?" trên Facebook
// @namespace    https://facebook.com
// @version      1.0
// @description  Ẩn các phần không mong muốn trên Facebook Web
// @author       Bạn
// @match        *://www.facebook.com/*
// @grant        none
// @run-at       document-idle
// ==/UserScript==

(function() {
    'use strict';

    function hideElements() {
        const selectors = [
            'div[aria-label="Reels"]',
            'a[href*="/reels/"]',
            'div[role="complementary"]',
            'div[aria-label="Lối tắt"]',
            'div[aria-label="khay tin"]',
            'div[aria-label="Tạo bài viết"]',
            'div[role="feed"] > div:first-child'
        ];

        selectors.forEach(selector => {
            document.querySelectorAll(selector).forEach(el => {
                el.style.display = 'none';
            });
        });
    }

    // Ẩn ngay khi trang tải xong
    hideElements();

    // Quan sát DOM để ẩn lại nếu Facebook tải nội dung động
    const observer = new MutationObserver(hideElements);
    observer.observe(document.body, { childList: true, subtree: true });

})();
