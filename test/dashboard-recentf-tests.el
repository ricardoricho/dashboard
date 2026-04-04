;;; dashboard-recentf-tests.el -- Tests for dashboard-recentf  -*- lexical-binding: t; -*-
;; Commentary:

;;; Code:

(defun dashboard-recentf--setup-tests ()
  "Setup recentf in dashboard buffer before running test-suite."
  (use-package dashboard
    :load-path "./"
    :demand t
    :config (dashboard-open)
    :custom
    (dashboard-items '((recents . 5)))))

(defun dashboard-recentf--build-recent-files-for-tests ()
  "Create recent file list."
  (require 'recentf)
  (let ((filename (expand-file-name (symbol-value 'recentf-save-file))))
    (write-region
     "(setq recentf-list\n'(\n\"~/recent-file\"\n\"~/dummy-file\"\n))\n"
     nil filename)))

(defun dashboard-recentf--clean-tests ()
  "Clear test environment.  Delete recentf file and set recentf-list to nil."
  (recentf-mode -1)
  (and (boundp 'recentf-list) (setq recentf-list nil))
  (delete-file (expand-file-name (symbol-value 'recentf-save-file))))

(ert-deftest dashboard-recentf--no-recents-test ()
  "Test dsahboard show no items message when there are no recent files."
  (dashboard-recentf--setup-tests)
  (with-current-buffer (get-buffer (symbol-value 'dashboard-buffer-name))
    (let ((dashboard-content (buffer-string)))
      (should (string-match-p "Recent Files:" dashboard-content))
      (should (string-match-p "No items" dashboard-content)))))

(ert-deftest dashboard-recentf--show-recent-files-test ()
  "Show list of recent files."
  (dashboard-recentf--build-recent-files-for-tests)
  (dashboard-recentf--setup-tests)
  (unwind-protect
      (with-current-buffer (get-buffer (symbol-value 'dashboard-buffer-name))
        (let ((dashboard-content (buffer-string)))
          (should (string-match-p "Recent Files:" dashboard-content))
          (should (string-match-p "recent-file" dashboard-content))
          (should (string-match-p "dummy-file" dashboard-content))))
    (dashboard-recentf--clean-tests)))

(ert-deftest dashboard-recentf--delete-recent-file-test ()
  "Delete a recent file."
  (dashboard-recentf--build-recent-files-for-tests)
  (dashboard-recentf--setup-tests)
  (unwind-protect
      (with-current-buffer (get-buffer (symbol-value 'dashboard-buffer-name))
        (let ((dashboard-content (buffer-string)))
          (should (string-match-p "Recent Files:" dashboard-content))
          (should (string-match-p "recent-file" dashboard-content))
          (should (string-match-p "dummy-file" dashboard-content)))
        (and (fboundp 'dashboard--goto-section)
             (apply 'dashboard--goto-section '(recents)))
        (and (fboundp 'dashboard-remove-item-under)
             (call-interactively 'dashboard-remove-item-under))
        (let ((new-content (buffer-string)))
          (should-not (string-match-p "recent-file" new-content))
          (should (string-match-p "dummy-file" new-content))))
    (dashboard-recentf--clean-tests)))


(provide 'dashboard-recentf-tests)
;;; dashboard-recentf-tests.el ends here
