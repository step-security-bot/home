{
  # auto create parent directories
  mkdir = ''mkdir -pv'';
  rm = ''rm -i'';
  cp = ''cp -i'';
  mv = ''mv -i'';
  gcd = ''cd (git root)'';
  ls = ''exa'';
  ll = ''exa -l'';
  la = ''exa -a'';
  l = ''exa -lah'';
  t = ''exa --tree -L 2'';
  wget = ''wget -c'';
  map = ''xargs -n1'';
  chos4 = ''curl -s chmouel.com/tmp/vincent.kubeconfig.gpg|gpg --decrypt > ~/.kube/config.os4 && export KUBECONFIG=~/.kube/config.os4'';
}
