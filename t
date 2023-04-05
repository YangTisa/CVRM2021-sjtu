void Compensator::ShengJin(double a, double b, double c, double d,
                           vector<double>& X123) {
  /************************************************************************/
  /* 盛金公式求解三次方程的解
     德尔塔f=B^2-4AC
     这里只要了实根，虚根需要自己再整理下拿出来
  */
  /************************************************************************/
  double A = b * b - 3 * a * c;
  double B = b * c - 9 * a * d;
  double C = c * c - 3 * b * d;
  double f = B * B - 4 * A * C;
  double i_value;
  double Y1, Y2;
  if (fabs(A) < 1e-6 && fabs(B) < 1e-6)  // 公式1
  {
    X123.push_back(-b / (3 * a));
    X123.push_back(-b / (3 * a));
    X123.push_back(-b / (3 * a));
  } else if (fabs(f) < 1e-6)  // 公式3
  {
    double K = B / A;
    X123.push_back(-b / a + K);
    X123.push_back(-K / 2);
    X123.push_back(-K / 2);
  } else if (f > 1e-6)  // 公式2
  {
    Y1 = A * b + 3 * a * (-B + sqrt(f)) / 2;
    Y2 = A * b + 3 * a * (-B - sqrt(f)) / 2;
    double Y1_value = (Y1 / fabs(Y1)) * pow((double)fabs(Y1), 1.0 / 3);
    double Y2_value = (Y2 / fabs(Y2)) * pow((double)fabs(Y2), 1.0 / 3);
    X123.push_back((-b - Y1_value - Y2_value) / (3 * a));  // 虚根我不要
    // 虚根还是看看吧，如果虚根的i小于0.1，则判定为方程的一根吧。。。
    i_value = sqrt(3.0) / 2 * (Y1_value - Y2_value) / (3 * a);
    if (fabs(i_value) < 1e-1) {
      X123.push_back((-b + 0.5 * (Y1_value + Y2_value)) / (3 * a));
    }
  } else if (f < -1e-6)  // 公式4
  {
    double T = (2 * A * b - 3 * a * B) / (2 * A * sqrt(A));
    double S = acos(T);
    X123.push_back((-b - 2 * sqrt(A) * cos(S / 3)) / (3 * a));
    X123.push_back((-b + sqrt(A) * (cos(S / 3) + sqrt(3.0) * sin(S / 3))) /
                   (3 * a));
    X123.push_back((-b + sqrt(A) * (cos(S / 3) - sqrt(3.0) * sin(S / 3))) /
                   (3 * a));
  }
}
void Compensator::CompensateGravity(Armor& armor, const double ballet_speed,
                                    component::AimMethod method) {
  component::Euler aiming_eulr = armor.GetAimEuler();
  if (method == component::AimMethod::kARMOR || aiming_eulr.pitch < 0) {
    double A = tan(aiming_eulr.pitch);
    double B =
        kG * distance_ * cos(aiming_eulr.pitch) / (2 * pow(ballet_speed, 2));
    double a = 1;
    double b = A * A;
    double c = 2 * A * B;
    double d = B * B - 1;
    vector<double>& X123;
    vector<double>& X_f;
    ShengJin(a, b, c, d, X123);
    // selsct
    for (int i = 0; i < X123.size(); i++) {
      if (0 < X123[i] &&
          X123[i] < cos(10 / 180 * M_PI) * cos(10 / 180 * M_PI)) {
        X_f.push_back(X123[i]);
      }
    }
    vector<double>& pitch_f;
    for (int i = 0; i < X_f.size(); i++) {
      double cos_b = sqrt(X_f);
      double bt = acos(cos_b);
      pitch_f.push_back(bt);
    }
    if (pitch_f.empty() {
          SPDLOG_WARN("No result!");
          return;
        })
    std::sort(pitch_f.begin(),pitch_f.end(),[](double &a, double &b){
        return a > b;
    };
    double result = pitch_f.front();
    SPDLOG_INFO("Distance : {} <=> Now pitch : {}", distance_, pitch);
    aiming_eulr.pitch = result;
  } else if (0) {
    // (void)ballet_speed;
    aiming_eulr.yaw -= 0.3 / 180 * CV_PI;
    double pitch = aiming_eulr.pitch;
    double A = -((distance_ * kG) / (ballet_speed * ballet_speed));
    double B = tan(pitch) / cos(pitch);
    /* B = sin(pitch) / (cos(pitch) * cos(pitch)) */
    double C = 1 / cos(pitch);
    double D = B * B + C * C;
    double E = 2 * B * (A - B);
    double F = (A - B) * (A - B) - C * C;

    for (int i = 0; i < 2; i++) {
    double temporary_result =
        0.5 * acos((E + pow(-1, i) * sqrt(E * E - 4 * D * F)) / (2 * D));
    SPDLOG_DEBUG("temporary_pitch{}", temporary_result);

    if (temporary_result > 0 && temporary_result > pitch &&
        temporary_result < 0.5) {
      pitch = 1.3 * temporary_result;
      SPDLOG_INFO("{} <=> {}", aiming_eulr.pitch, pitch);
      continue;
    }
    }
    aiming_eulr.pitch = pitch;
  } else {
    if (0) {
    SPDLOG_WARN("start {}, {}", aiming_eulr.yaw, aiming_eulr.pitch);
    aiming_eulr.yaw += 0.4 / 180 * CV_PI;
    if (aiming_eulr.pitch < 0.15) {
      aiming_eulr.pitch += 1.7 / 180 * CV_PI;
      SPDLOG_WARN("0.1");
    } else if (aiming_eulr.pitch < 0.25) {
      aiming_eulr.pitch += 1.8 / 180 * CV_PI;
      SPDLOG_WARN("0.2");
    } else if (aiming_eulr.pitch < 0.3) {
      aiming_eulr.pitch += 2.5 / 180 * CV_PI;
      SPDLOG_WARN("0.3");
    } else if (aiming_eulr.pitch < 0.4) {
      aiming_eulr.pitch += 2.5 / 180 * CV_PI;
      SPDLOG_WARN("0.4");
    } else if (aiming_eulr.pitch < 0.5) {
      aiming_eulr.pitch += 2.8 / 180 * CV_PI;
      SPDLOG_WARN("0.5");
    } else {
      aiming_eulr.pitch += 3.0 / 180 * CV_PI;
      SPDLOG_WARN("else");
    }
    SPDLOG_WARN(" end {}, {}", aiming_eulr.yaw, aiming_eulr.pitch);
    } else {
    // double pitch = acct(2 * (1 - tan(aiming_eulr.pitch)));
    // aiming_eulr.pitch = pitch * 1.3;
    // aiming_eulr.yaw += 0.4 / 180 * CV_PI;
    }
  }
  armor.SetAimEuler(aiming_eulr);
  SPDLOG_DEBUG("Armor Euler is setted");
}
