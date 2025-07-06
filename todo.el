(defcustom todo-file "~/.todo"
  "File containing outstanding todo items."
  :type 'string
  :group 'todo)

(defcustom todo-file-completed "~/.todo.completed"
  "File containing completed todo items."
  :type 'string
  :group 'todo)

;; Mode state
(defvar-local todo-edit-mode-p nil
  "Non-nil when in todo edit mode.")

;; Edit mode keymap (minimal - mostly self-insert)
(defvar todo-edit-mode-map
  (let ((map (make-sparse-keymap)))
    ;; Only C-c C-c to exit edit mode
    (define-key map (kbd "C-c C-c") 'todo-toggle-edit)
    map)
  "Keymap for todo edit mode.")

;; Main mode keymap that switches between view and edit
(defvar todo-mode-map
  (make-sparse-keymap)
  "Keymap for todo-mode.")

;; Global keybinding
(global-set-key (kbd "C-.") 'todo-buffer-display)

;; Mode definition
(defun todo-mode ()
  "Major mode for managing todos with vi-like keybindings."
  (interactive)
  (kill-all-local-variables)
  (setq major-mode 'todo-mode)
  (setq mode-name "Todo")
  (setq todo-edit-mode-p nil)
  (use-local-map (todo-make-view-mode-map))
  (todo-ensure-file-format)
  (setq mode-line-format
        (list "-" 'mode-line-mule-info 'mode-line-client 'mode-line-modified
              " " 'mode-line-buffer-identification "   "
              '(:eval (if todo-edit-mode-p "Todo-Edit" "Todo"))
              " " 'mode-line-position
              '(vc-mode vc-mode)
              " " 'mode-line-modes 'mode-line-misc-info 'mode-line-end-spaces))
  (run-hooks 'todo-mode-hook)
  (message "Todo mode enabled"))

;; View mode keymap (default)
(defun todo-make-view-mode-map ()
  "Create the view mode keymap fresh each time."
  (let ((map (make-sparse-keymap)))

    ;; Quick create
    (define-key map "0" 'todo-create-p0)
    (define-key map "1" 'todo-create-p1)
    (define-key map "2" 'todo-create-p2)
    (define-key map "3" 'todo-create-p3)
    (define-key map "4" 'todo-create-p4)

    ;; Update priority
    (define-key map (kbd "C-c 0") 'todo-update-p0)
    (define-key map (kbd "C-c 1") 'todo-update-p1)
    (define-key map (kbd "C-c 2") 'todo-update-p2)
    (define-key map (kbd "C-c 3") 'todo-update-p3)
    (define-key map (kbd "C-c 4") 'todo-update-p4)

    ;; Edit mode toggle
    (define-key map (kbd "C-c C-c") 'todo-toggle-edit)

    ;; Move within priority section
    (define-key map "J" 'todo-move-down)
    (define-key map "K" 'todo-move-up)
    (define-key map "N" 'todo-move-down)
    (define-key map "P" 'todo-move-up)

    ;; Navigation
    (define-key map "j" 'todo-next-line)
    (define-key map "k" 'todo-previous-line)
    (define-key map "n" 'todo-next-line)
    (define-key map "p" 'todo-previous-line)

    ;; Actions
    (define-key map "a" 'todo-create)
    (define-key map "o" 'todo-create-pcurrent)
    (define-key map "c" 'todo-complete)
    (define-key map "x" 'todo-cancel)

    ;; Priority
    (define-key map "," 'todo-raise-priority)
    (define-key map "." 'todo-lower-priority)

    map))

(defun todo-ensure-file-format ()
  "Ensure the todo file has the proper section headers, preserving existing content."
  (save-excursion
    (goto-char (point-min))
    (unless (looking-at "Priority 0")
      ;; File doesn't have proper format, initialize it
      (erase-buffer)
      (insert "Priority 0\n")
      (insert "-------------------------------------------------------------------------------\n")
      (insert "\n")
      (insert "Priority 1\n")
      (insert "-------------------------------------------------------------------------------\n")
      (insert "\n")
      (insert "Priority 2\n")
      (insert "-------------------------------------------------------------------------------\n")
      (insert "\n")
      (insert "Priority 3\n")
      (insert "-------------------------------------------------------------------------------\n")
      (insert "\n")
      (insert "Priority 4\n")
      (insert "-------------------------------------------------------------------------------\n")
      (insert "\n")
      (save-buffer))))

(defun todo-buffer-display ()
  "Display the todo buffer and activate todo-mode."
  (interactive)
  (let ((todo-buffer (get-file-buffer todo-file)))
    (if todo-buffer
        (switch-to-buffer todo-buffer)
      (find-file todo-file))
    ;; Activate todo major mode
    (todo-mode)))

;;=============================================================================
;; Todo mode functions
;;=============================================================================

(defun todo-create-p0 (&optional insertFirst)
  "Create a priority 0 todo."
  (interactive)
  (let ((description (read-from-minibuffer "Description: ")))
    (todo-create "0" description (if insertFirst insertFirst t))))

(defun todo-create-p1 (&optional insertFirst)
  "Create a priority 1 todo."
  (interactive)
  (let* ((description (read-from-minibuffer "Description: "))
         (due-date (read-from-minibuffer "Due date (YYYY-MM-DD): ")))
    (todo-create "1" description (if insertFirst insertFirst t) due-date)))

(defun todo-create-p2 (&optional insertFirst)
  "Create a priority 2 todo."
  (interactive)
  (let* ((description (read-from-minibuffer "Description: "))
         (due-date (read-from-minibuffer "Due date (YYYY-MM-DD): ")))
    (todo-create "2" description (if insertFirst insertFirst t) due-date)))

(defun todo-create-p3 (&optional insertFirst)
  "Create a priority 3 todo."
  (interactive)
  (let* ((description (read-from-minibuffer "Description: "))
         (due-date (read-from-minibuffer "Due date (YYYY-MM-DD): ")))
    (todo-create "3" description (if insertFirst insertFirst t) due-date)))

(defun todo-create-p4 (&optional insertFirst)
  "Create a priority 4 todo."
  (interactive)
  (let* ((description (read-from-minibuffer "Description: "))
         (due-date (read-from-minibuffer "Due date (YYYY-MM-DD): ")))
    (todo-create "4" description (if insertFirst insertFirst t) due-date)))

(defun todo-create (&optional priority description insertFirst due-date)
  "Create a new todo item with PRIORITY and DESCRIPTION.
If INSERTFIRST is explicitly nil, insert at current position; otherwise insert at top of section."
  (interactive)
  (let* ((priority (or priority
                       (completing-read "Priority (1-4): " '("1" "2" "3" "4") nil t)))
         (description (or description
                          (read-from-minibuffer "Description: ")))
         (due-date (or due-date
                       (read-from-minibuffer "Due date (YYYY-MM-DD): "))))

    ;; Validate inputs
    (when (or (not description) (string= description ""))
      (error "Description cannot be empty"))

    (when (not (member priority '("0" "1" "2" "3" "4")))
      (error "Priority must be 0, 1, 2, 3, or 4"))

    ;; Create the todo line
    (let ((todo-line (if (and due-date (not (string= due-date "")))
                         (format "[%s] %s" due-date description)
                       description)))
      (if (not (eq insertFirst nil))
          ;; Insert at top of priority section (original behavior)
          (let ((insert-point (todo-find-priority-section priority)))
            (if insert-point
                (progn
                  (goto-char insert-point)
                  (open-line 1)
                  (insert todo-line)
                  (beginning-of-line)
                  (save-buffer)
                  (message "Todo added to Priority %s: %s" priority todo-line))
              (error "Could not find Priority %s section" priority)))
        ;; Insert at current position
        (progn
          (open-line 1)
          (insert todo-line)
          (beginning-of-line)
          (save-buffer)
                   (message "Todo added to Priority %s: %s" priority todo-line))))))

(defun todo-create-pcurrent ()
  "Create a todo item in the current priority section at current position."
  (interactive)
  (cond
   ;; If on priority header or separator, do nothing
   ((or (looking-at "^Priority [0-9]")
        (looking-at "^-+$"))
    (message "Cannot create todo on header or separator line"))

   ;; Otherwise, find current priority and create item
   (t
    (let ((current-priority (todo-get-current-priority)))
      (if current-priority
          (cond
           ((string= current-priority "1") (todo-create-p1 nil))
           ((string= current-priority "2") (todo-create-p2 nil))
           ((string= current-priority "3") (todo-create-p3 nil))
           ((string= current-priority "4") (todo-create-p4 nil)))
        (message "Could not determine current priority section"))))))

(defun todo-update-p0 ()
  "Update current todo to priority 0."
  (interactive)
  (todo-update-priority "0"))

(defun todo-update-p1 ()
  "Update current todo to priority 1."
  (interactive)
  (todo-update-priority "1"))

(defun todo-update-p2 ()
  "Update current todo to priority 2."
  (interactive)
  (todo-update-priority "2"))

(defun todo-update-p3 ()
  "Update current todo to priority 3."
  (interactive)
  (todo-update-priority "3"))

(defun todo-update-p4 ()
  "Update current todo to priority 4."
  (interactive)
  (todo-update-priority "4"))

(defun todo-raise-priority ()
  "Raise priority of current todo by 1 (lower number = higher priority)."
  (interactive)
  (let ((current-priority (todo-get-current-priority)))
    (when (and current-priority (> (string-to-number current-priority) 0))
      (let ((new-priority (number-to-string (1- (string-to-number current-priority)))))
        (todo-update-priority new-priority)))))

(defun todo-lower-priority ()
  "Lower priority of current todo by 1 (higher number = lower priority)."
  (interactive)
  (let ((current-priority (todo-get-current-priority)))
    (when (and current-priority (< (string-to-number current-priority) 4))
      (let ((new-priority (number-to-string (1+ (string-to-number current-priority)))))
        (todo-update-priority new-priority)))))

(defun todo-update-priority (priority)
  "Update the priority of the current todo item to PRIORITY."
  (beginning-of-line)
  (when (looking-at-todo)
    (kill-whole-line)
    (goto-char (todo-find-priority-section priority))
    (yank)
    (previous-line 1)
    (beginning-of-line)
    (save-buffer)
    (message "Todo moved to priority %s" priority)))

(defun todo-next-line ()
  "Move to next todo item, skipping headers, separators, and blank lines."
  (interactive)
  (forward-line 1)
  (while (and (not (eobp)) (not (looking-at-todo)))
    (forward-line 1))
  (when (eobp)
    ;; Reached end, go to last todo item
    (while (and (not (bobp)) (not (looking-at-todo)))
      (forward-line -1)))
  (beginning-of-line))

(defun todo-previous-line ()
  "Move to previous todo item, skipping headers, separators, and blank lines."
  (interactive)
  (forward-line -1)
  (while (and (not (bobp)) (not (looking-at-todo)))
    (forward-line -1))
  (when (bobp)
    ;; Reached beginning, go to first todo item
    (while (and (not (eobp)) (not (looking-at-todo)))
      (forward-line 1)))
  (beginning-of-line))

(defun todo-toggle-edit ()
  "Toggle between edit and view modes."
  (interactive)
  (if todo-edit-mode-p
      ;; Exit edit mode
      (progn
        (setq todo-edit-mode-p nil)
        (use-local-map (todo-make-view-mode-map))
        (force-mode-line-update)
        (message "Exiting edit mode"))
    ;; Enter edit mode
    (setq todo-edit-mode-p t)
    (use-local-map todo-edit-mode-map)
    (force-mode-line-update)
    (message "Entering edit mode (C-c C-c to exit)")))

(defun todo-cancel ()
  "Cancel the current todo and move it to cancelled file."
  (interactive)
  (save-excursion
    (beginning-of-line)
    (when (looking-at-todo)
      ;; We're on a todo item line
      (let* ((line-start (point))
             (line-end (progn (end-of-line) (point)))
             (todo-line (buffer-substring line-start line-end))
             (todo-buffer (current-buffer))
             (todo-cancelled-buffer (get-file-buffer (concat todo-file ".cancelled")))
             (comments (read-from-minibuffer "Cancellation reason: ")))

        ;; Delete the todo line from current buffer
        (delete-region line-start (min (+ 1 line-end) (point-max)))
        (save-buffer)

        ;; Switch to cancelled buffer and add the item
        (if todo-cancelled-buffer
            (switch-to-buffer todo-cancelled-buffer)
          (find-file (concat todo-file ".cancelled")))

        (end-of-buffer)
        (insert (get-date) " " todo-line "\n")
        (when (and comments (not (string= comments "")))
          (insert "    Reason: " comments "\n"))
        (save-buffer)
        (kill-buffer (current-buffer))

        (switch-to-buffer todo-buffer)
        (message "Todo cancelled")))))

(defun todo-complete ()
  "Mark the current todo as done and move it to completed file."
  (interactive)
  (save-excursion
    (beginning-of-line)
    (when (and (not (looking-at "^Priority [0-9]"))
               (not (looking-at "^-+$"))
               (not (looking-at "^$")))
      ;; We're on a todo item line
      (let* ((line-start (point))
             (line-end (progn (end-of-line) (point)))
             (todo-line (buffer-substring line-start line-end))
             (todo-buffer (current-buffer))
             (todo-complete-buffer (get-file-buffer todo-file-completed))
             (comments (read-from-minibuffer "Comments: ")))

        ;; Delete the todo line from current buffer
        (delete-region line-start (min (+ 1 line-end) (point-max)))
        (save-buffer)

        ;; Switch to completed buffer and add the item
        (if todo-complete-buffer
            (switch-to-buffer todo-complete-buffer)
          (find-file todo-file-completed))

        (goto-char (point-min))
        (insert (get-date) " " todo-line "\n")
        (when (and comments (not (string= comments "")))
          (insert "    " comments "\n"))
        (save-buffer)
        (kill-buffer (current-buffer))

        (switch-to-buffer todo-buffer)
        (message "Todo completed")))))

(defun todo-move-down ()
  "Move current todo down one position."
  (interactive)
  (beginning-of-line)
  (when (looking-at-todo)
    ;; Check if we're the last item in Priority 4 section
    (let ((in-priority-4 (string= (todo-get-current-priority) "4"))
          (is-last-in-p4 (save-excursion
                           (forward-line 1)
                           (while (and (not (eobp)) (not (looking-at-todo)))
                             (forward-line 1))
                           (eobp))))

      (if (and in-priority-4 is-last-in-p4)
          (message "Cannot move down - already at last item")
        ;; 1. Cut the todo item (without the newline)
        (kill-line)
        (delete-char 1)  ; Delete the newline separately

        ;; 2. Move to next line
        (forward-line 0)  ; Stay at current position after kill-whole-line

        ;; 3. Find insertion point and insert
        (if (looking-at-todo)
            ;; Next line is a todo - go to end of line, return, paste
            (progn
              (end-of-line)
              (newline)
              (yank)
              ;; Cursor is now at end of inserted line, move to beginning
              (beginning-of-line))
          ;; Next line is not a todo - find first line of new priority section
          (progn
            ;; Skip non-todo lines until we find a priority section
            (while (and (not (eobp)) (not (looking-at "^Priority [0-9]")))
              (forward-line 1))
            ;; Go to insertion point (2 lines down from priority header)
            (forward-line 2)
            (open-line 1)
            (yank)
            ;; Cursor is now at end of inserted line, move to beginning
            (beginning-of-line)))))))

(defun todo-move-up ()
  "Move current todo up one position."
  (interactive)
  (beginning-of-line)
  (when (looking-at-todo)

    ;; 1. Check if 2 lines above is Priority 0 line
    (let ((two-lines-up (save-excursion
                          (forward-line -2)
                          (looking-at "^Priority 0$"))))
      (if two-lines-up
          (message "Cannot move up - already at first item")

        ;; 2. Cut the item
        (kill-line)
        (delete-char 1)  ; Delete the newline separately

        ;; 3. Check what's on the prior line
        (forward-line -1)
        (if (looking-at-todo)
            ;; Prior line is a todo item - paste before it
            (progn
              (beginning-of-line)
              (open-line 1)
              (yank)
              (beginning-of-line))

          ;; Prior line is separator - move to priority line, then blank line, paste
          (progn
            (forward-line -3)  ; Move to priority line
            (forward-line 1)   ; Move to blank line after priority
            (open-line 1)
            (yank)
            (beginning-of-line)))))))

;;=============================================================================
;; Utilities
;;=============================================================================

;; Helper function to check if current line is a todo item
(defun looking-at-todo ()
  "Return t if current line is a todo item (not header, separator, or blank)."
  (save-excursion
    (beginning-of-line)
    (and (not (looking-at "^Priority [0-9]"))  ; Not a priority header
         (not (looking-at "^-+$"))             ; Not a separator line
         (not (looking-at "^$")))))            ; Not a blank line

(defun todo-find-priority-section (priority)
  "Find the insertion point for the given priority section."
  (save-excursion
    (goto-char (point-min))
    (re-search-forward (concat "^Priority " priority "$"))
    (forward-line 2)  ; Skip header and separator line
    (beginning-of-line)
    (point)))

(defun todo-get-current-priority ()
  "Get the priority number of the current item based on which section it's in."
  (save-excursion
    (let ((current-pos (point)))
      (goto-char (point-min))
      (cond
       ((and (re-search-forward "^Priority 0$" nil t)
             (< (point) current-pos)
             (or (not (re-search-forward "^Priority 1$" nil t))
                 (> (point) current-pos)))
        "0")
       ((and (goto-char (point-min))
             (re-search-forward "^Priority 1$" nil t)
             (< (point) current-pos)
             (or (not (re-search-forward "^Priority 2$" nil t))
                 (> (point) current-pos)))
        "1")
       ((and (goto-char (point-min))
             (re-search-forward "^Priority 2$" nil t)
             (< (point) current-pos)
             (or (not (re-search-forward "^Priority 3$" nil t))
                 (> (point) current-pos)))
        "2")
       ((and (goto-char (point-min))
             (re-search-forward "^Priority 3$" nil t)
             (< (point) current-pos)
             (or (not (re-search-forward "^Priority 4$" nil t))
                 (> (point) current-pos)))
        "3")
       ((and (goto-char (point-min))
             (re-search-forward "^Priority 4$" nil t)
             (< (point) current-pos))
        "4")
       (t nil)))))

(defun get-date ()
  "Get current date in MM/DD format."
  (let* ((current-date (current-time-string))
         (month (substring current-date 4 7))
         (day (substring current-date 8 10)))

    (if (eq ?  (aref day 0))
        (setq day (concat "0" (substring day 1))))

    (cond
     ((equal month "Jan") (concat "01/" day))
     ((equal month "Feb") (concat "02/" day))
     ((equal month "Mar") (concat "03/" day))
     ((equal month "Apr") (concat "04/" day))
     ((equal month "May") (concat "05/" day))
     ((equal month "Jun") (concat "06/" day))
     ((equal month "Jul") (concat "07/" day))
     ((equal month "Aug") (concat "08/" day))
     ((equal month "Sep") (concat "09/" day))
     ((equal month "Oct") (concat "10/" day))
     ((equal month "Nov") (concat "11/" day))
     ((equal month "Dec") (concat "12/" day)))))

;; Development helper function
(defun todo-reload ()
  "Reload todo mode definitions and refresh current buffer."
  (interactive)
  (eval-buffer)
  ;; Clear the cached keymap so it gets rebuilt
  (setq todo-mode-map nil)
  ;; Reactivate the mode
  (when (eq major-mode 'todo-mode)
    (todo-mode)))

(provide 'todo)
;;; todo.el ends here
