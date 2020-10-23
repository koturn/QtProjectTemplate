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
{
  Q_OBJECT;

public:
  /*!
   * @brief Initialize window.
   * @param [in] parent  Parent widget
   */
  explicit MainWindow(QWidget* parent = nullptr);

private:
  //! Use Interface of this class.
  Ui::MainWindow ui;
};  // class MainWindow


#endif  // MAINWINDOW_H
