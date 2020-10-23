/*!
 * @file MainWindow.h
 * @brief Declaration of MainWindow
 * @version 1.0
 */
#ifndef MAINWINDOW_H
#define MAINWINDOW_H

#include "ui_MainWindow.h"


/*!
 * @brief Main window of this application.
 */
class MainWindow
  : public QMainWindow
  , private Ui::MainWindow
{
  Q_OBJECT;

public:
  /*!
   * @brief Initialize window.
   * @param [in] parent  Parent widget
   */
  explicit MainWindow(QWidget* parent = Q_NULLPTR);
};  // class MainWindow


#endif  // MAINWINDOW_H
