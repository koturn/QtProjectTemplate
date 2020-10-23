#include "MainWindow.h"
#include <QApplication>


/*!
 * @brief Entry point of the program
 * @param [in] argc  A number of command-line arguments
 * @param [in] argv  Command line arguments
 * @return  Exit-status
 */
int
main(int argc, char* argv[])
{
  QApplication a{argc, argv};
  MainWindow w;
  w.show();
  return a.exec();
}
