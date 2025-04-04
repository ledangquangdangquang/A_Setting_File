// ==UserScript==
// @name         Ẩn Shorts trên YouTube (Cập nhật)
// @namespace    https://youtube.com
// @version      1.1
// @description  Ẩn Shorts trên trang chính, sidebar và trang tìm kiếm của YouTube
// @author       Bạn
// @match        *://www.youtube.com/*
// @grant        none
// @run-at       document-idle
// ==/UserScript==

(function() {
    'use strict';

    function hideShorts() {
        const shortsSelectors = [
            'ytd-rich-section-renderer[content-type="shorts"]', // Shorts trên trang chính
            'ytd-reel-shelf-renderer', // Dòng Shorts
            'ytd-guide-entry-renderer[title="Shorts"]', // Mục Shorts trong sidebar
            'a[title="Shorts"]', // Link Shorts trong menu bên trái
            'ytd-grid-video-renderer a[href*="shorts/"]', // Video Shorts trong danh sách gợi ý
            'ytd-video-renderer a[href*="shorts/"]', // Shorts trên trang tìm kiếm
            '.style-scope.ytd-rich-section-renderer', // Ẩn thêm các phần tử có class này
            '.style-scope ytd-watch-next-secondary-results-renderer', // Ẩn trang chủ
            '.style-scope ytd-two-column-browse-results-renderer', // Ẩn cột phải
        ];

        shortsSelectors.forEach(selector => {
            document.querySelectorAll(selector).forEach(el => {
                el.style.display = 'none';
            });
        });
    }

    // Ẩn ngay khi trang tải xong
    hideShorts();

    // Quan sát thay đổi DOM để ẩn Shorts nếu nó xuất hiện lại
    const observer = new MutationObserver(hideShorts);
    observer.observe(document.body, { childList: true, subtree: true });

})();
