{ pkgs, ... }:
{
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    initExtra = ''
      source ${pkgs.grml-zsh-config}/etc/zsh/zshrc

      nr() {
        PKG=$1
        shift
        exec nix run nixpkgs\#$PKG -- "$@"
      }

      bp-upload() {
        FOLDER=/var/www/pterodactyl
        VERSION=dev-vic
        sudo rsync -av . /var/www/pterodactyl/ --chown nginx:nginx --exclude '/blueprint' --exclude '/routes' --include '/resources/views/blueprint'
        sudo sed -E -i "s*::v*$VERSION*g" $FOLDER/app/BlueprintFramework/Services/PlaceholderService/BlueprintPlaceholderService.php
        sudo sed -i "s~::f~$FOLDER~g" $FOLDER/app/BlueprintFramework/Services/PlaceholderService/BlueprintPlaceholderService.php
        sudo sed -i "s~::f~$FOLDER~g" $FOLDER/app/BlueprintFramework/Libraries/ExtensionLibrary/Admin/BlueprintAdminLibrary.php
        sudo sed -i "s~::f~$FOLDER~g" $FOLDER/app/BlueprintFramework/Libraries/ExtensionLibrary/Client/BlueprintClientLibrary.php
        sudo sed -i "s/NOTINSTALLED/INSTALLED/g" $FOLDER/app/BlueprintFramework/Services/PlaceholderService/BlueprintPlaceholderService.php
      }
    '';

    shellAliases = {
      ptero-upload = "sudo rsync -a . /var/www/pterodactyl/ --delete-after --chown nginx:nginx --exclude node_modules --exclude storage/logs --exclude storage/app/public";
      ptero-devbuild = "yarn clean && yarn build && ptero-upload";
    };
  };

  programs.zoxide = {
    enable = true;
    options = [
      "--cmd"
      "cd"
    ];
  };
}
