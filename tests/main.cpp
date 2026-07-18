#include <QtTest>
#include <QCoreApplication>
#include "viewmodels/VehicleStatusViewModel.h"

class TestViewModels : public QObject
{
    Q_OBJECT

public:
    TestViewModels() {}
    ~TestViewModels() {}

private slots:
    void testInitialValues() {
        VehicleStatusViewModel vm;
        QCOMPARE(vm.speed(), 0.0);
        QCOMPARE(vm.rpm(), 0);
        QCOMPARE(vm.gear(), QString("P"));
        QCOMPARE(vm.isWarning(), false);
    }

    void testSetSpeed() {
        VehicleStatusViewModel vm;
        QSignalSpy spy(&vm, &VehicleStatusViewModel::speedChanged);
        
        vm.setSpeed(120.5);
        QCOMPARE(vm.speed(), 120.5);
        QCOMPARE(spy.count(), 1);
        
        // Setting same value should not emit signal again
        vm.setSpeed(120.5);
        QCOMPARE(spy.count(), 1);
    }

    void testSetRpm() {
        VehicleStatusViewModel vm;
        QSignalSpy spy(&vm, &VehicleStatusViewModel::rpmChanged);
        
        vm.setRpm(3000);
        QCOMPARE(vm.rpm(), 3000);
        QCOMPARE(spy.count(), 1);
    }

    void testSetGear() {
        VehicleStatusViewModel vm;
        QSignalSpy spy(&vm, &VehicleStatusViewModel::gearChanged);
        
        vm.setGear("D");
        QCOMPARE(vm.gear(), QString("D"));
        QCOMPARE(spy.count(), 1);
    }

    void testSetWarning() {
        VehicleStatusViewModel vm;
        QSignalSpy spy(&vm, &VehicleStatusViewModel::isWarningChanged);
        
        vm.setIsWarning(true);
        QCOMPARE(vm.isWarning(), true);
        QCOMPARE(spy.count(), 1);
    }
    
    void testUpdateRawTelemetry() {
        VehicleStatusViewModel vm;
        
        // RPM = 3000 -> speed = 3000 * 0.03 = 90
        // Speed > 80 -> Gear 5
        // Error = 0, VBat = 12.0 -> Warning = false
        vm.updateRawTelemetry(3000, 12.0, 0);
        
        QCOMPARE(vm.rpm(), 3000);
        QCOMPARE(vm.speed(), 90.0);
        QCOMPARE(vm.gear(), QString("5"));
        QCOMPARE(vm.isWarning(), false);
        
        // Test warning logic
        vm.updateRawTelemetry(3000, 10.0, 0); // VBat < 10.5
        QCOMPARE(vm.isWarning(), true);
        
        vm.updateRawTelemetry(3000, 12.0, 1); // Error != 0
        QCOMPARE(vm.isWarning(), true);
    }
};

QTEST_MAIN(TestViewModels)

#include "main.moc"
