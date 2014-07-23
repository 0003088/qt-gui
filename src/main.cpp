#include <QApplication>
#include <QQmlApplicationEngine>
#include <QtQml>
#include <QMetaType>

#include "treeviewmodel.hpp"
#include "confignode.hpp"

int main(int argc, char* argv[])
{
	QApplication app(argc, argv);

	qRegisterMetaType<TreeViewModel> ("TreeViewModel");
	qRegisterMetaType<ConfigNode> ("ConfigNode");

	QLocale locale;

	qDebug() << QLocale::system().name() << " with argc: " << argc;

	if (argc == 2)
	{
	    locale =  QLocale(QLocale::German);
	} else {
	    locale =  QLocale(QLocale::English);
	}

	QTranslator tr;
	tr.load(QString(":/qml/i18n/lang_") + locale.name() + QString(".qm"));
	app.installTranslator(&tr);

	QQmlApplicationEngine engine;
	QQmlContext* ctxt = engine.rootContext();

	kdb::KDB kdb;
	kdb::KeySet config;
	kdb.get(config, "/");

	TreeViewModel* model = new TreeViewModel;
	model->populateModel(config);
	ctxt->setContextProperty("externTreeModel", QVariant::fromValue(model));
	engine.load(QUrl(QStringLiteral("qrc:/qml/main.qml")));

//    PrintVisitor printer;
//    model->accept(printer);

//    KeySetVisitor ksVisit;
//    model->accept(ksVisit);

	int ret = app.exec();
	qDebug() << "Editor exited at " << QTime::currentTime().toString("hh:mm:ss:zzz") << " ret: " << ret;
	return ret;
}
