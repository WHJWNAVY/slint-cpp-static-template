#include "appwindow.h"
#include <stdlib.h>
#include <stdio.h>
#include <windows.h>
#include <windef.h>
#include <roapi.h>

HRESULT RoGetActivationFactory(
    HSTRING activatableClassId,
    REFIID  iid,
    void    **factory
) {
    return S_OK;
}

int main(int argc, char **argv)
{
    auto ui = AppWindow::create();

    ui->on_request_increase_value([&]{
        ui->set_counter(ui->get_counter() + 1);
    });

    ui->run();
    return 0;
}
