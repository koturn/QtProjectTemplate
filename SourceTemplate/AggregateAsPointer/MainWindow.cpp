/*!
 * @file MainWindow.cpp
 * @brief Definition of MainWindow
 * @version 1.0
 */
#include "MainWindow.h"
#include "ui_MainWindow.h"


MainWindow::MainWindow(QWidget* parent)
  : QMainWindow{parent}
  , ui{new Ui::MainWindow}
{
  ui->setupUi(this);
}


MainWindow::~MainWindow()
{
}
