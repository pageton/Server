# Git config for Server — no GPG signing (no keys on server).
{ constants, ... }:
{
  programs.git = {
    enable = true;
    settings = {
      user = { inherit (constants.user) name email; };

      # Force SSH for GitHub — faster and authenticated
      url = {
        "git@github.com:".insteadOf = "https://github.com/";
      };

      pull.rebase = true;
      push = {
        autoSetupRemote = true;
        gpgSign = false;
      };

      merge.conflictstyle = "zdiff3";
      rerere.enabled = true;
      rebase = {
        autoStash = true;
        autoSquash = true;
        updateRefs = true;
      };

      diff.algorithm = "histogram";

      fetch = {
        prune = true;
        pruneTags = true;
        fsckobjects = true;
      };

      transfer.fsckobjects = true;
      receive.fsckobjects = true;

      column.ui = "auto";
      branch.sort = "-committerdate";
      tag.sort = "-version:refname";
      log.date = "iso";
      status.showUntrackedFiles = "all";

      init.defaultBranch = "main";
      help.autocorrect = "prompt";

      alias = {
        st = "status";
        co = "checkout";
        br = "branch";
        lg = "log --oneline --graph --decorate";
        lga = "log --oneline --graph --decorate --all";
        ad = "add";
        cm = "commit -m";
        amend = "commit --amend --no-edit";
        pl = "pull";
        ps = "push";
        df = "diff";
        dft = "diff --cached";
        rs = "restore";
        rst = "restore --staged";
        rb = "rebase";
        rbi = "rebase -i";
        rset = "reset";
        tg = "tag";
        tga = "tag -a";
        cl = "clean -fdi";
        sm = "submodule";
        smu = "submodule update --init --recursive";
        rmt = "remote";
        rmtv = "remote -v";
        cp = "cherry-pick";
        stsh = "stash";
        stshl = "stash list";
        stsha = "stash apply";
        stshd = "stash drop";
        cfg = "config --list";
        cfgg = "config --global --list";
        ign = "!git check-ignore -v";
        recent = "branch --sort=-committerdate --format='%(committerdate:relative)\\t%(refname:short)'";
        undo = "reset --soft HEAD~1";
        aliases = "!git config --get-regexp alias | sort";
      };
    };

    includes = [
      {
        condition = "hasconfig:remote.*.url:https://github.com/**";
        contents.user.email = constants.user.githubEmail;
      }
      {
        condition = "hasconfig:remote.*.url:git@github.com:*/**";
        contents.user.email = constants.user.githubEmail;
      }
    ];

    ignores = [
      ".cache/"
      ".DS_Store"
      ".idea/"
      "*.swp"
      ".direnv/"
      "node_modules"
      "result"
      "result-*"
    ];
  };
}
