#pragma once
#include "config/config.hpp"
#include "service-registry.hpp"
#include <QColor>
#include <QObject>
#include <QVariant>

class ConfigBridge : public QObject {
  Q_OBJECT

  Q_PROPERTY(qreal windowOpacity READ windowOpacity NOTIFY changed)
  Q_PROPERTY(int borderWidth READ borderWidth NOTIFY changed)
  Q_PROPERTY(int borderRounding READ borderRounding NOTIFY changed)
  Q_PROPERTY(int shadowSize READ shadowSize NOTIFY changed)
  Q_PROPERTY(int windowWidth READ windowWidth NOTIFY changed)
  Q_PROPERTY(int windowHeight READ windowHeight NOTIFY changed)
  Q_PROPERTY(bool emacsMode READ emacsMode NOTIFY changed)
  Q_PROPERTY(bool considerPreedit READ considerPreedit NOTIFY changed)
  Q_PROPERTY(bool activateOnSingleClick READ activateOnSingleClick NOTIFY changed)
  Q_PROPERTY(bool blurEnabled READ blurEnabled NOTIFY changed)
  // Shared single source of truth for the launcher's screen-fraction band: the QML window clamp and the
  // dynamic ui_scale bounds both read these so they can never drift apart.
  Q_PROPERTY(qreal maxScreenFraction READ maxScreenFraction CONSTANT)
  Q_PROPERTY(qreal minScreenFraction READ minScreenFraction CONSTANT)
  Q_PROPERTY(bool dynamicScaleBoundsEnabled READ dynamicScaleBoundsEnabled NOTIFY changed)

signals:
  void changed();

public:
  explicit ConfigBridge(QObject *parent = nullptr) : QObject(parent) {
    connect(ServiceRegistry::instance()->config(), &config::Manager::configChanged, this,
            [this] { emit changed(); });
  }

  qreal windowOpacity() const { return cfg().launcherWindow.opacity; }

  int borderWidth() const {
    auto &csd = cfg().launcherWindow.clientSideDecorations;
    return csd.enabled ? csd.borderWidth : 0;
  }

  int borderRounding() const {
    auto &csd = cfg().launcherWindow.clientSideDecorations;
    return csd.enabled ? csd.rounding : 0;
  }

  int shadowSize() const {
    auto &csd = cfg().launcherWindow.clientSideDecorations;
    return csd.enabled ? csd.shadowSize : 0;
  }

  int windowWidth() const { return cfg().launcherWindow.size.width; }
  int windowHeight() const { return cfg().launcherWindow.size.height; }
  bool emacsMode() const { return cfg().keybinding == "emacs"; }
  bool considerPreedit() const { return cfg().considerPreedit; }
  bool activateOnSingleClick() const { return cfg().activateOnSingleClick; }
  bool blurEnabled() const { return cfg().launcherWindow.blur.enabled; }

  qreal maxScreenFraction() const { return config::WINDOW_MAX_SCREEN_FRACTION; }
  qreal minScreenFraction() const { return config::WINDOW_MIN_SCREEN_FRACTION; }
  bool dynamicScaleBoundsEnabled() const { return cfg().launcherWindow.dynamicScaleBounds; }

  Q_INVOKABLE static QColor withAlpha(const QColor &c, qreal alpha) {
    return QColor::fromRgbF(c.redF(), c.greenF(), c.blueF(), alpha);
  }

  // [min, max] ui_scale offered for a screen of the given logical (devicePixelRatio-adjusted) size.
  // Returns the per-screen dynamic bounds when enabled, otherwise the static clamp. QML passes its
  // window's Screen.desktopAvailableWidth/Height.
  Q_INVOKABLE QVariantList scaleBoundsForScreen(qreal logicalW, qreal logicalH) const {
    const auto &win = cfg().launcherWindow;
    if (!win.dynamicScaleBounds || logicalW <= 0 || logicalH <= 0)
      return {config::SCALE_MIN, config::SCALE_MAX};
    const auto b = config::computeDynamicScaleBounds(logicalW, logicalH, appliedUiScale(), win.size.width,
                                                     win.size.height);
    return {b.min, b.max};
  }

private:
  static const config::ConfigValue &cfg() { return ServiceRegistry::instance()->config()->value(); }

  // The QT_SCALE_FACTOR currently in effect, regardless of whether we or the user set it (defaults to
  // 1.0 when unset). Authoritative because Qt's reported screen geometry already reflects it.
  static qreal appliedUiScale() {
    bool ok = false;
    const qreal v = qEnvironmentVariable("QT_SCALE_FACTOR").toDouble(&ok);
    return ok && v > 0 ? v : 1.0;
  }
};
