/*!
 * @file MainWindow.h
 * @brief Declaration of MainWindow
 * @version 1.0
 */
#ifndef MAINWINDOW_H
#define MAINWINDOW_H

#include <QMainWindow>
// #include <memory>


QT_BEGIN_NAMESPACE
namespace Ui
{
class MainWindow;
}  // namespace Ui
QT_END_NAMESPACE


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
  explicit MainWindow(QWidget* parent = Q_NULLPTR);
  /*!
   * @brief Do nothing but this dtor is neccesary because
   * Ui::MainWindow is incomplete type.
   */
  ~MainWindow();

private:
  //! Use Interface of this class.
  QScopedPointer<Ui::MainWindow> ui;
  // std::unique_ptr<Ui::MainWindow> ui;
};  // class MainWindow


#endif  // MAINWINDOW_H
