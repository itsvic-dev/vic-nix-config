{ pp, lib, fetchFromGitHub }:
with pp;
let
  pypikaTortoise = buildPythonPackage rec {
    pname = "pypika-tortoise";
    version = "0.6.1";
    src = fetchPypi {
      pname = "pypika_tortoise";
      inherit version;
      sha256 = "sha256-NuwsiMJVue1+9JpgaM3qwQ2v1N3+uCggXTr8CSUH/Do=";
    };
    pyproject = true;

    nativeBuildInputs = [ poetry-core ];
  };
in rec {
  tortoiseORM = buildPythonPackage rec {
    pname = "tortoise-orm";
    version = "0.25.1";
    src = fetchPypi {
      pname = "tortoise_orm";
      inherit version;
      sha256 = "sha256-TVv9E9V1CTX/5jamslWXxcj1HEflty11CdcS7aGiOf4=";
    };
    doCheck = false;
    pyproject = true;

    nativeBuildInputs = [ poetry-core ];

    propagatedBuildInputs = [ pypikaTortoise iso8601 aiosqlite pytz ];
  };

  aerich = buildPythonPackage rec {
    pname = "aerich";
    version = "0.9.1";
    src = fetchPypi {
      inherit pname version;
      sha256 = "sha256-Ypr771kCY1xB9BDdBd75hMAuBeYtiiAgIQoppKrhkAE=";
    };
    doCheck = false;
    pyproject = true;

    nativeBuildInputs = [ poetry-core ];

    propagatedBuildInputs =
      [ tortoiseORM asyncclick pydantic dictdiffer tomlkit ];
  };
}
